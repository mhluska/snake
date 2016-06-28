const THREE = require('three');
const World = require('./world');
const Snake = require('./snake');
const Const = require('./const');
const Tests = require('../test/tests');
const times = require('./utils/times');
const makeVoxelMesh = require('./utils/make-voxel-mesh');
const assert = require('assert');
const assertTruthy = require('./utils/assert-truthy');
const getUnitVectorDimension = require('./utils/get-unit-vector-dimension');

class Game {
  constructor(container, { keys = true, enemies = 5 } = {}) {
    this._keys = keys;
    this._enemies = enemies;
    this._container = container;
    this._world = new World();

    [this._scene, this._camera, this._renderer] = this._setupScene(this._container);

    this.setup();

    this._container.appendChild(this._renderer.domElement);
    this.setupEventListeners(keys);
  }

  static tests() {
    Tests.run();
  }

  run() {
    this._animate();
  }

  // NOTE(maros): This should be idempotent because it is called whenever the
  // player dies.
  setup() {
    this._steps = 0;
    this._debugMeshes = new Set();

    // TODO(maros): The game seems to only work if the starting face index is 3.
    // The bug is likely related to the camera up vector. Fix that.
    const playerFaceIndex = 3;

    this._cameraFace = this._world._faceVectors[playerFaceIndex];
    this._cameraUpCached = this._camera.up.clone();
    this._snake = this._initSnake(this._cameraFace);

    this._snakeEnemies = this._world._faceVectors
      .slice(0, playerFaceIndex)
      .concat(this._world._faceVectors.slice(playerFaceIndex + 1))
      .slice(0, this._enemies)
      .map(v => this._initSnakeEnemy(v));

    // We make this a function of the number of enemies + player so that they
    // don't run out of food.
    // TODO(maros): This should also be a function of the snake speed.
    this._foodDropRate = Math.floor(200 / (this._snakeEnemies.length + 1));

    this._lastTime = window.performance.now();

    // TODO(maros): Use the `Animation` class.
    this._cameraAnimation = {
      primaryAxis: null,
      primaryMultiplier: null,
      secondaryAxis: null,
      secondaryMultiplier: null,
      position: null,
      targetPosition: null,
      animating: false,
      doneCallback: function(){},
    };

    this._scene.add(this._world.mesh);
    this._scene.add(this._snake.mesh);
    this._scene.add(...this._snakeEnemies.map(enemy => enemy.mesh));

    for (let i of times(Const.FOOD_START)) {
      this._addFoodToScene(i);
    }
  }

  reset() {
    this._world.reset();
    this._clearSceneMeshes();
    this._setupCameraOrientation(this._camera, this._world);
    this.setup();
  }

  setupEventListeners(keys) {
    window.addEventListener('resize',  this._updateScreenSizeResize.bind(this));

    if (keys) {
      window.addEventListener('keydown', this._updateSnakeDirection.bind(this));
    }
  }

  _clearSceneMeshes() {
    for (let i = this._scene.children.length; i >= 0; i -= 1) {
      const child = this._scene.children[i];
      if (!(child instanceof THREE.Camera)) {
        this._scene.remove(child);
      }
    }
  }

  _initSnake(face, options) {
    assertTruthy(this._world, this._camera);
    return new Snake(this._world, this._camera.up.clone(), face, options);
  }

  // TODO(maros): The initial direction for the enemy snakes is incorrect. It
  // has no effect because enemy snakes are in AI mode. This may be a problem
  // if they enter manual movement mode if food runs out.
  _initSnakeEnemy(face) {
    return this._initSnake(face, { type: 'enemy', color: Const.Colors.ENEMY, speed: 0.05 });
  }

  _setupCameraOrientation(camera, world) {
    camera.up.set(0, 1, 0);
    camera.position.copy(world._faceVectors[3].clone().multiplyScalar(Const.CAMERA_DISTANCE));
    camera.lookAt(world.mesh);
  }

  // TODO(maros): Move camera to its own class.
  _setupScene(container) {
    assertTruthy(this._world);

    let scene    = new THREE.Scene();
    let camera   = new THREE.PerspectiveCamera(75, null, 1, 10000);
    let renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });

    this._setupCameraOrientation(camera, this._world);
    this._updateScreenSize(container, camera, renderer);

    let light1   = new THREE.PointLight(Const.Colors.LIGHT, 0.75);
    let light2   = new THREE.PointLight(Const.Colors.LIGHT, 0.75);
    let distance = Const.MESH_SIZE * 1.5;

    light1.position.set(distance, distance, distance);
    light2.position.copy(light1.position).negate();

    camera.add(light1);
    camera.add(light2);

    scene.add(camera);

    renderer.shadowMap.enabled = true;

    return [scene, camera, renderer];
  }

  _updateScreenSize(container, camera, renderer) {
    let width  = container.clientWidth;
    let height = container.clientHeight;

    camera.aspect = width / height;
    camera.updateProjectionMatrix();

    renderer.setSize(width, height);
  }

  _updateScreenSizeResize() {
    assertTruthy(this._container, this._camera, this._renderer);
    this._updateScreenSize(this._container, this._camera, this._renderer);
  }

  _updateSnakeDirection(event) {
    const direction = { 38: 'up', 39: 'right', 40: 'down', 37: 'left' }[event.keyCode];

    if (!direction) {
      return;
    }

    let directionVector = this._cameraUpCached.clone();
    switch (direction) {
      case 'left':
        directionVector.cross(this._cameraFace);
      case 'down':
        directionVector.cross(this._cameraFace);
      case 'right':
        directionVector.cross(this._cameraFace);
        break;
    }

    this._snake.enqueueDirection(directionVector);
  }

  _processMesh(promise) {
    if (promise) {
      promise.then((foodMesh) => {
        this._scene.remove(foodMesh);
      });
    }
  }

  _updateSnake(timeDelta) {
    this._processMesh(this._snake.move(timeDelta));
    this._updateDebugInfo();
    this._updateCamera(this._snake.face, timeDelta);
  }

  _updateSnakeEnemy(snake, timeDelta) {
    this._processMesh(snake.move(timeDelta));
  }

  _addFoodToScene() {
    const food = this._world.spawnFood();
    if (food) {
      this._scene.add(food.mesh);
    }
  }

  _removeSnakeEnemyFromScene(snake) {
    assert(snake.type === 'enemy', 'Snake is not of type enemy');

    const index = this._snakeEnemies.indexOf(snake);

    if (index === -1) {
      return;
    }

    this._snakeEnemies.splice(index, 1);
    this._scene.remove(snake.mesh);
  }

  _addDebugMesh(voxel, color) {
    let mesh = voxel.mesh;

    if (!mesh) {
      mesh = makeVoxelMesh(Const.TILE_SIZE, color, voxel.position);
      this._debugMeshes.add(mesh);
      this._scene.add(mesh);
    }

    mesh.material.color.setHex(color);
  }

  _updateDebugInfo() {
    if (!Const.DEBUG) {
      return;
    }

    for (let voxel of this._snake._path._data.slice(0, -1)) {
      this._addDebugMesh(voxel, Const.Colors.DEBUG_SNAKE);
    }
  }

  _update() {
    const now = window.performance.now();
    const timeDelta = now - this._lastTime;
    this._lastTime = now;

    this._updateSnake(timeDelta);
    this._snakeEnemies.forEach(enemy => this._updateSnakeEnemy(enemy, timeDelta));

    // Add food to the game every x frames.
    // TODO(maros): Don't update per frame but per time delta.
    if (this._steps % this._foodDropRate === 0) {
      this._addFoodToScene();
      this._updateDebugInfo();
    }

    this._steps += 1;
  }

  _render() {
    this._renderer.render(this._scene, this._camera);
  }

  _animate() {
    try {
      this._update();
    } catch(error) {
      if (error.snake && error.snake.type === 'enemy') {
        this._removeSnakeEnemyFromScene(error.snake);
      } else {
        this.reset();
      }

      this._update();
    }

    this._render();
    requestAnimationFrame(() => this._animate());
  }

  _circular(x) {
    return Math.sqrt((Const.CAMERA_DISTANCE * Const.CAMERA_DISTANCE) - (x * x));
  }

  // Cubic approximation of a bezier transform.
  _bezier(x) {
    const max = Const.CAMERA_DISTANCE;

    x = max - x;             // Change input from 500 -> 0 to 0 -> 500
    x /= max;                // Bring it in the range [0, 1]
    x = ((--x) * x * x) + 1; // Apply the transform
    x *= max;                // Back to the range [0, 500]
    x = max - x;             // Back to 500 -> 0

    return x;
  }

  _updateCamera(face, timeDelta) {
    assertTruthy(this._camera, this._cameraFace, this._world, this._cameraAnimation);

    if (!this._cameraFace.equals(face)) {
      // We finish any previously running animation. This is helpful when
      // rapidly turning multiple corners.
      this._cameraAnimation.doneCallback();

      const dot = this._camera.up.dot(face);

      if (dot !== 0) {
        this._cameraUpCached = this._cameraFace.clone();
        this._cameraUpCached.multiplyScalar(-dot);
      }

      this._cameraAnimation.doneCallback = () => {
        this._camera.up.copy(this._cameraUpCached);
        this._camera.position.copy(this._cameraAnimation.targetPosition);
        this._camera.rotation.set(0, 0, 0);
        this._camera.lookAt(this._world.mesh.position);
        this._cameraAnimation.animating = false;
      };

      const faceDirection = face.clone().sub(this._cameraFace);

      this._cameraAnimation.primaryAxis = getUnitVectorDimension(this._cameraFace);
      this._cameraAnimation.secondaryAxis = getUnitVectorDimension(face);
      this._cameraAnimation.primaryMultiplier = -faceDirection[this._cameraAnimation.primaryAxis];
      this._cameraAnimation.secondaryMultiplier = faceDirection[this._cameraAnimation.secondaryAxis];
      this._cameraAnimation.position = this._camera.position.clone();
      this._cameraAnimation.targetPosition = face.clone().multiplyScalar(Const.CAMERA_DISTANCE);
      this._cameraAnimation.animating = true;

      this._cameraFace = face;
    }

    if (!this._cameraAnimation.animating) {
      return;
    }

    const x = this._cameraAnimation.primaryAxis;
    const y = this._cameraAnimation.secondaryAxis;
    const speed = 0.75;
    const delta = this._cameraAnimation.targetPosition[x] - this._cameraAnimation.position[x];
    const distanceRemaining = Math.max(0, Math.abs(delta) - (speed * timeDelta));

    // We keep track of a reference position which is not affected by our
    // bezier transform. We do this so that the effects don't accumulate across
    // animation frames.
    this._cameraAnimation.position[x] = this._cameraAnimation.primaryMultiplier * distanceRemaining;

    // Apply bezier to the primary dimension and circular motion to the range.
    // The result is a smooth, circular camera movement.
    this._camera.position[x] = this._cameraAnimation.primaryMultiplier   * this._bezier(distanceRemaining);
    this._camera.position[y] = this._cameraAnimation.secondaryMultiplier * this._circular(this._camera.position[x]);

    // This allows us to avoid worrying about rotation coordinates for the
    // camera.
    this._camera.lookAt(this._world.mesh.position);

    if (this._camera.position.equals(this._cameraAnimation.targetPosition)) {
      this._cameraAnimation.doneCallback();
    }
  }
}

if (typeof window.snakeGameLoaded === 'function') {
  window.snakeGameLoaded(Game);
}

module.exports = Game;
