'use strict';

var THREE = require('three');

class Voxel {
  constructor() {
    this.mesh = this._makeMesh(this.constructor.SIZE);
  }

  _makeMesh(size) {
    var geometry = new THREE.BoxGeometry(size, size, size);
    var material = new THREE.MeshBasicMaterial({ color: 0xff0000, wireframe: true });
    var mesh     = new THREE.Mesh(geometry, material);

    return mesh;
  }
}

Voxel.SIZE = 20;

module.exports = Voxel;
