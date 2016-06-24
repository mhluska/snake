'use strict';

let THREE = require('three');
let World = require('./world');
let Snake = require('./snake');
let Queue = require('./queue');
let Const = require('./const');
let Tests = require('../test/tests');
let makeVoxelMesh = require('./utils/make-voxel-mesh');
let assertTruthy = require('./utils/assert-truthy');
let getUnitVectorDimension = require('./utils/get-unit-vector-dimension');

class Game {
  constructor(container, { keys = true } = {}) {
    this._container = container;
    this._steps = 0;
    this._moveQueue = new Queue([], this.constructor.MAX_QUEUED_MOVES);
    this._debugMeshes = new Set();

    [this._scene, this._camera, this._renderer] = this._setupScene(container);

    this._world = new World();
    this._cameraFace = this._world._faceVectors[3];
    this._cameraUpCached = this._camera.up.clone();

    this._snake      = this._initSnake(this._cameraFace);
    this._snakeEnemy = this._initSnake(this._cameraFace.clone().negate(), { type: 'enemy', color: Const.Colors.ENEMY });

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

    this._container.appendChild(this._renderer.domElement);

    this._scene.add(this._world.mesh);
    this._scene.add(this._snake.mesh);
    this._scene.add(this._snakeEnemy.mesh);

    window.addEventListener('resize',  this._updateScreenSizeResize.bind(this));

    if (keys) {
      window.addEventListener('keydown', this._updateSnakeDirection.bind(this));
    }
  }

  static tests() {
    Tests.run();
  }

  run() {
    this._animate();
  }

  _initSnake(face, options) {
    assertTruthy(this._world, this._camera);
    return new Snake(this._world, this._camera.up.clone(), face, options);
  }

  // TODO(maros): Move camera to its own class.
  _setupScene(container) {
    let scene    = new THREE.Scene();
    let camera   = new THREE.PerspectiveCamera(75, null, 1, 10000);
    let renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });

    camera.position.z = Const.CAMERA_DISTANCE;

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

    this._moveQueue.enqueue(directionVector);
  }

  _addVoxel(voxel) {
    if (!voxel) return;
    this._scene.add(voxel.mesh);
  }

  _processMesh(promise) {
    if (promise) {
      promise.then((foodMesh) => {
        this._scene.remove(foodMesh);
      });
    }
  }

  _updateSnake(timeDelta) {
    // TODO(maros): This direction-updating mechanism should be a function of
    // the snake.
    // Update snake direction.
    let move = this._moveQueue.dequeue();
    if (move) {
      this._snake.direction = move;
    }

    this._processMesh(this._snake.move(timeDelta));

    this._updateDebugInfo();
    this._updateCamera(this._snake.face, timeDelta);
  }

  _updateSnakeEnemy(snake, timeDelta) {
    this._processMesh(snake.move(timeDelta));
  }

  _updateWorld() {
    this._addVoxel(this._world.spawnFood());
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

    // TODO(maros): Figure out why Set iteration is not working.
    for (let debugMesh of this._debugMeshes._c.values()) {
      if (!this._world._occupiedTiles[debugMesh.position.toString()] || this._snake._path._data.indexOf(debugMesh) === -1) {
        this._debugMeshes.delete(debugMesh);
        this._scene.remove(debugMesh);
      }
    }

    // TODO(maros): Figure out why Map iteration is not working.
    for (let key of Object.keys(this._world._occupiedTiles)) {
      this._addDebugMesh(this._world._occupiedTiles[key], Const.Colors.DEBUG_PATH);
    }

    for (let voxel of this._snake._path._data.slice(0, -1)) {
      this._addDebugMesh(voxel, Const.Colors.DEBUG_SNAKE);
    }
  }

  // TODO(maros): Don't update per frame but per time delta. Use
  // `window.performance.now`.
  _update() {
    const now = window.performance.now();
    const timeDelta = now - this._lastTime;
    this._lastTime = now;

    this._updateSnake(timeDelta);
    this._updateSnakeEnemy(this._snakeEnemy, timeDelta);

    // Add food to the game every 100 frames.
    if (this._steps % 100 === 0) {
      this._updateWorld();
      this._updateDebugInfo();
    }

    this._steps += 1;
  }

  _render() {
    this._renderer.render(this._scene, this._camera);
  }

  _animate() {
    this._update();
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
    const speed = 1;
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

Game.MAX_QUEUED_MOVES = 2;

if (typeof window.snakeGameLoaded === 'function') {
  window.snakeGameLoaded(Game);
}

module.exports = Game;
