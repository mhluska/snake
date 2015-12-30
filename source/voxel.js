'use strict';

var THREE = require('three');

class Voxel {
  constructor(position) {
    this.mesh = this._makeMesh(this.constructor.SIZE);
    this.mesh.position.set(...position);
  }

  _makeMesh(size) {
    var geometry = new THREE.BoxGeometry(size, size, size);
    var material = new THREE.MeshBasicMaterial({ color: 0x9586de  });
    var mesh     = new THREE.Mesh(geometry, material);

    return mesh;
  }
}

Voxel.SIZE = 20;

module.exports = Voxel;
