const THREE = require('three');
const Voxel = require('../voxel');

module.exports = function(size, color, position=null) {
  var geometry = new THREE.BoxGeometry(size, size, size);
  var material = new THREE.MeshLambertMaterial({ color: color });
  var mesh     = new THREE.Mesh(geometry, material);

  if (position) {
    mesh.position.set(...position);

    // TODO(maros): Remove this side effect.
    Voxel.findOrCreate(position, mesh);
  }

  return mesh;
};
