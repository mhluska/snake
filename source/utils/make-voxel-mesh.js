const THREE = require('three');
const Voxel = require('../voxel');

module.exports = function(size, color, position=null) {
  let geometry = new THREE.BoxGeometry(size, size, size);
  let material = new THREE.MeshLambertMaterial({ color: color });
  let mesh     = new THREE.Mesh(geometry, material);

  if (position) {
    mesh.position.set(...position);

    // TODO(maros): Remove this side effect.
    Voxel.at(position, mesh);
  }

  return mesh;
};
