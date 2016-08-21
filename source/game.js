const THREE = require('three');
const World = require('./world');
const Snake = require('./snake');
const Const = require('./const');
const Animation = require('./animation');
const Tests = require('../test/tests');
const times = require('./utils/times');
const makeVoxelMesh = require('./utils/make-voxel-mesh');
const assert = require('assert');
const assertTruthy = require('./utils/assert-truthy');
const getUnitVectorDimension = require('./utils/get-unit-vector-dimension');
const adjacentUnitVector = require('./utils/adjacent-unit-vector');

class Game {
  constructor(container, { keys = true, enemies = 5, zoom = 1 } = {}) {
    this._keys = keys;
    this._enemies = enemies;
    this._container = container;
    this._world = new World();
    this._zoom = zoom;

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
    this._cameraAnimation = null;

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
    assertTruthy(this._world);
    return new Snake(this._world, adjacentUnitVector(face), face, options);
  }

  _initSnakeEnemy(face) {
    return this._initSnake(face, { type: 'enemy', color: Const.Colors.ENEMY, speed: 0.05 });
  }

  _cameraDistance() {
    return Const.CAMERA_DISTANCE / this._zoom;
  }

  _setupCameraOrientation(camera, world) {
    camera.up.set(0, 1, 0);
    camera.position.copy(world._faceVectors[3].clone().multiplyScalar(this._cameraDistance()));
    camera.lookAt(world.mesh);
  }

  // TODO(maros): Move camera to its own class.
  _setupScene(container) {
    assertTruthy(this._world);

    const scene    = new THREE.Scene();
    const camera   = new THREE.PerspectiveCamera(75, null, 1, 10000);
    const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });

    this._setupCameraOrientation(camera, this._world);
    this._updateScreenSize(container, camera, renderer);

    const intensity = 1;
    const light1    = new THREE.PointLight(Const.Colors.LIGHT, intensity);
    const light2    = new THREE.PointLight(Const.Colors.LIGHT, intensity);
    const distance  = Const.MESH_SIZE * 1.5;

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

  _updateSnake() {
    this._processMesh(this._snake.move());
    this._updateDebugInfo();
    this._updateCamera(this._snake.face);
  }

  _updateSnakeEnemy(snake) {
    this._processMesh(snake.move());
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

    snake.mesh.children.map(mesh => {
      // TODO(maros): We wrap in try/catch because of the pseodo-snake pieces
      // that can exist on edges. Make those not part of the snake mesh.
      try {
        this._world.enable(mesh.position);
      } catch(error) {}
    });

    this._snakeEnemies.splice(index, 1);
    this._scene.remove(snake.mesh);
  }

  _addDebugMesh(voxel, color) {
    let mesh = voxel.mesh;

    if (!mesh) {
      mesh = makeVoxelMesh(Const.TILE_SIZE, { color: color, position: voxel.position });
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

    Animation.update(timeDelta);
    this._updateSnake();
    this._snakeEnemies.forEach(enemy => this._updateSnakeEnemy(enemy));

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
    const distance = this._cameraDistance();
    return Math.sqrt((distance * distance) - (x * x));
  }
  _updateCamera(face) {
    if (this._cameraFace.equals(face)) {
      return;
    }

    if (this._cameraAnimation) {
      this._cameraAnimation.stop();
    }

    const primaryAxis         = getUnitVectorDimension(this._cameraFace);
    const secondaryAxis       = getUnitVectorDimension(face);
    const faceDirection       = face.clone().sub(this._cameraFace);
    const secondaryMultiplier = faceDirection[secondaryAxis];
    const dot                 = this._camera.up.dot(face);

    if (dot !== 0) {
      this._cameraUpCached = this._cameraFace.clone();
      this._cameraUpCached.multiplyScalar(-dot);
    }

    this._cameraAnimation = Animation.add({
      start:  this._camera.position.clone(),
      end:    face.clone().multiplyScalar(this._cameraDistance()),
      easing: 'easeOut',

      step:  (percent, start) => {
        this._camera.position[primaryAxis]   = start[primaryAxis];
        this._camera.position[secondaryAxis] = secondaryMultiplier * this._circular(start[primaryAxis]);
        this._camera.lookAt(this._world.mesh.position);
      },

      done:  (end) => {
        this._camera.up.copy(this._cameraUpCached);
        this._camera.position.copy(end);
        this._camera.rotation.set(0, 0, 0);
        this._camera.lookAt(this._world.mesh.position);
      },
    });

    this._cameraFace = face;
  }
}

if (typeof window.snakeGameLoaded === 'function') {
  window.snakeGameLoaded(Game);
}

module.exports = Game;
