'use strict';

var THREE = require('three');

module.exports = class Utils {
  static times(count, callback) {
    for (let index of Array(count).keys()) {
      callback(index);
    }
  }

  static random(min, max) {
    if (arguments.length === 1) {
      max = min;
      min = 0;
    }

    return Math.floor(Math.random() * (max - min)) + min;
  }

  static adjacentUnitVector(vector3) {
    if (vector3.length() !== 1) {
      throw new Error('Non unit vector passed to adjacentUnitVector.');
    }

    let units = vector3.toArray();
    units.unshift(units.pop());
    return new THREE.Vector3(...units);
  }

  static shuffle(array) {
    for (let index = 0; index < array.length - 1; index += 1) {
      let item        = array[index];
      let randomIndex = this.random(index + 1, array.length);
      let temp        = array[randomIndex];

      array[randomIndex] = item;
      array[index] = temp;
    }

    return array;
  }

  static makeVoxelMesh(size, color, position = null) {
    var geometry = new THREE.BoxGeometry(size, size, size);
    var material = new THREE.MeshLambertMaterial({ color: color });
    var mesh     = new THREE.Mesh(geometry, material);

    if (position) {
      mesh.position.set(...position);
    }

    return mesh;
  }

};
