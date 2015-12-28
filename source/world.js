'use strict';

var THREE = require('three');
var Voxel = require('./voxel');

/*
  A game world of size N has 6 faces corresponding to the 6 faces of a cube.
  Each face has a 2D NxN array.

  Movement between faces happens as you would expect on a cube: moving up from 0
  goes to 5, moving right from 0 goes to 4 etc.

           . . .
           . 0 .
   . . . . . . . . .
   . 1 . 2 . 3 . 4 .
   . . . . . . . . .
           . 5 .
           . . .
*/

class World {
  constructor() {
    this.mesh   = this._makeMesh();
    this.lights = this._makeLights();
  }

  update() {
  }

  faceIndexToVector(face) {
    let points = ({
      0: [0, 1, 0],
      1: [0, 0, -1],
      2: [-1, 0, 0],
      3: [0, 0, 1],
      4: [1, 0, 0],
      5: [0, -1, 0]
    })[face];

    return new THREE.Vector3(...points);
  }

  vectorToFaceIndex(vector) {
    return ({
      '0,1,0':  0,
      '0,0,-1': 1,
      '-1,0,0': 2,
      '0,0,1':  3,
      '1,0,0':  4,
      '0,-1,0': 5,
    })[vector.toArray()];
  }

  position2to3(position) {
    let a = ((position[0] + 1) * Voxel.SIZE) - (Voxel.SIZE / 2) - (World.MESH_SIZE / 2);
    let b = ((position[1] + 1) * Voxel.SIZE) - (Voxel.SIZE / 2) - (World.MESH_SIZE / 2);
    let c = (Voxel.SIZE / 2) + (World.MESH_SIZE / 2);

    return [a, b, c];
  }

  nextFaceVector(direction, camera) {
    let up        = camera.up.clone();
    let target    = this.mesh.position.clone().sub(camera.position).normalize();
    let position  = null;

    if (direction === 'up')    position = up;
    if (direction === 'right') position = target.clone().cross(up);
    if (direction === 'down')  position = camera.up.clone().multiplyScalar(-1);
    if (direction === 'left')  position = target.clone().cross(up).negate();

    if (position === null) {
      throw new Error('Something went wrong in the nextFaceVector function.');
    }

    return position;
  }

  // TODO(maros): Make this not modify `meshPosition` in place.
  updateMeshPosition(meshPosition, direction, camera) {
    let position = this.nextFaceVector(direction, camera);
    position.multiplyScalar(Voxel.SIZE);
    meshPosition.add(position);
  }

  positionOutOfBounds(position) {
    return position[0] < 0 ||
           position[0] >= World.GAME_SIZE ||
           position[1] < 0 ||
           position[1] >= World.GAME_SIZE;
  }

  wrapPosition(position) {
    position[0] = (position[0] + World.GAME_SIZE) % World.GAME_SIZE;
    position[1] = (position[1] + World.GAME_SIZE) % World.GAME_SIZE;
  }

  nextFace(direction, camera) {
    return this.vectorToFaceIndex(this.nextFaceVector(direction, camera));
  }

  nextPosition(direction, position) {
    if (direction === 'up')    position[1] -= 1;
    if (direction === 'right') position[0] += 1;
    if (direction === 'down')  position[1] += 1;
    if (direction === 'left')  position[0] -= 1;

    let outside = this.positionOutOfBounds(position);

    if (outside) {
      this.wrapPosition(position);
    }

    return outside;
  }

  _makeMesh() {
    var geometry = new THREE.BoxGeometry(World.MESH_SIZE, World.MESH_SIZE, World.MESH_SIZE);
    var material = new THREE.MeshLambertMaterial({ color: 0xA5C9F3 });
    var mesh     = new THREE.Mesh(geometry, material);

    return mesh;
  }

  _makeLights() {
    let lights = [
      new THREE.PointLight(0xffffff, 2),
      new THREE.PointLight(0xffffff, 2)
    ];

    lights[0].position.set( 300,  300,  300);
    lights[1].position.set(-300, -300, -300);

    return lights;
  }
}

World.GAME_SIZE = 10;
World.MESH_SIZE = 200;

module.exports = World;
