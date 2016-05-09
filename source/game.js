'use strict';

var THREE = require('three');
var World = require('./world');
var Snake = require('./snake');
var Queue = require('./queue');
var Voxel = require('./voxel');
var Const = require('./const');
var Tests = require('../test/tests');
var { makeVoxelMesh } = require('./utils');

class Game {
  constructor(container) {
    this._container = container;
    this._steps = 0;
    this._moveQueue = new Queue([], this.constructor.MAX_QUEUED_MOVES);
    this._debugMeshes = new Set();

    [this._scene, this._camera, this._renderer] = this._setupScene(container);

    this._world = new World();
    this._snake = new Snake(this._world, this._camera.up);
    this._cameraFace = this._snake.face;

    this._container.appendChild(this._renderer.domElement);

    this._scene.add(this._world.mesh);
    this._scene.add(this._snake.mesh);
    this._scene.add(...this._world.lights);

    window.addEventListener('resize',  this._updateScreenSizeResize.bind(this));
    window.addEventListener('keydown', this._updateSnakeDirection.bind(this));
  }

  static tests() {
    Tests.run();
  }

  run() {
    this._animate();
  }

  // TODO(maros): Move camera to its own class.
  _setupScene(container) {
    let scene    = new THREE.Scene();
    let camera   = new THREE.PerspectiveCamera(75, null, 1, 10000);
    let renderer = new THREE.WebGLRenderer({ antialias: true });

    camera.position.z = Const.CAMERA_DISTANCE;
    renderer.shadowMap.enabled = true;

    this._updateScreenSize(container, camera, renderer);

    return [scene, camera, renderer];
  }

  _updateScreenSize(container, camera, renderer) {
    var width  = container.clientWidth;
    var height = container.clientHeight;

    camera.aspect = width / height;
    camera.updateProjectionMatrix();

    renderer.setSize(width, height);
  }

  _updateScreenSizeResize() {
    if (![this._container, this._camera, this._renderer].every(Boolean)) {
      throw new Error('Container, camera or renderer are not initialized.');
    }

    this._updateScreenSize(this._container, this._camera, this._renderer);
  }

  _updateSnakeDirection(event) {
    var direction = { 38: 'up', 39: 'right', 40: 'down', 37: 'left' }[event.keyCode];
    this._moveQueue.enqueue(direction);
  }

  _processVoxel(voxel) {
    if (!voxel) return;

    if (['food', 'poison'].includes(voxel.type)) {
      this._scene.remove(voxel.mesh);
      voxel.type = 'tile';
    }
  }

  _addVoxel(voxel) {
    if (!voxel) return;
    this._scene.add(voxel.mesh);
  }

  _updateSnake() {
    // Update snake direction.
    let move = this._moveQueue.dequeue();
    if (move) {
      this._snake.direction = move;
    }

    this._snake.move();
    this._updateCamera(this._snake.face, this._snake.direction);
    this._processVoxel(Voxel.findOrCreate(this._snake.position3));
  }

  _updateWorld() {
    this._addVoxel(this._world.spawnFood());
  }

  _addDebugMesh(voxel, color) {
    let mesh = voxel.mesh;

    if (!mesh) {
      mesh = makeVoxelMesh(Const.TILE_SIZE, color, voxel.position3);
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
      this._addDebugMesh(this._world._occupiedTiles[key], 0xf2ff9e);
    }

    for (let voxel of this._snake._path._data.slice(0, -1)) {
      this._addDebugMesh(voxel, 0xeb3b3b);
    }
  }

  // TODO(maros): Don't update per frame but per time delta. Use
  // `window.performance.now`.
  _update() {
    // Move snake every 5 frames.
    if (this._steps % 5 === 0) {
      this._updateSnake();
      this._updateDebugInfo();
    }

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

  _updateCamera(face, direction) {
    if (this._cameraFace.equals(face)) {
      return;
    }

    let dot = this._camera.up.dot(face);
    if (dot !== 0) {
      this._camera.up.copy(this._cameraFace.clone());
      this._camera.up.multiplyScalar(-dot);
    }

    this._camera.position.copy(face.clone().multiplyScalar(Const.CAMERA_DISTANCE));
    this._camera.lookAt(this._world.mesh.position);
    this._cameraFace = face;
  }
}

Game.MAX_QUEUED_MOVES = 2;

module.exports = Game;
