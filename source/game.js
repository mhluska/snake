'use strict';

var THREE = require('three');
var World = require('./world.js');
var Snake = require('./snake.js');

class Game {
  constructor(container) {
    this._container = container;
    this._steps = 0;

    [this._scene, this._camera, this._renderer] = this._setupScene(container);

    this._world = new World();
    this._snake = new Snake(this._world, this._camera);

    this._container.appendChild(this._renderer.domElement);

    this._scene.add(this._world.mesh);
    this._scene.add(this._snake.mesh);
    this._scene.add(...this._world.lights);

    window.addEventListener('resize', this._updateScreenSizeResize.bind(this));
    window.addEventListener('keydown', this._updateSnakeDirection.bind(this));
  }

  run() {
    this._animate();
  }

  _setupScene(container) {
    let scene    = new THREE.Scene();
    let camera   = new THREE.PerspectiveCamera(75, null, 1, 10000);
    let renderer = new THREE.WebGLRenderer({ antialias: true });

    camera.position.z = this.constructor.CAMERA_DISTANCE;
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
    this._snake.direction = direction;
  }

  _update() {
    if (this._steps % 5 === 0) {
      this._snake.move(this._updateCamera.bind(this));
    }

    this._world.update();
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

  _updateCamera(prevFace, face, direction) {
    let prevFaceVector = this._world.faceIndexToVector(prevFace);

    if (direction === 'up')   this._camera.up.copy(prevFaceVector.negate());
    if (direction === 'down') this._camera.up.copy(prevFaceVector);

    let faceVector = this._world.faceIndexToVector(face);

    this._camera.position.copy(faceVector.multiplyScalar(Game.CAMERA_DISTANCE));
    this._camera.lookAt(this._world.mesh.position);
  }
}

Game.CAMERA_DISTANCE = 500;

module.exports = Game;
