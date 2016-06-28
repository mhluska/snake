const THREE = require('three');
const to3Array = require('./to-3-array');

module.exports = function(size, color, position=null) {
  const geometry = new THREE.BoxGeometry(size, size, size);
  const material = new THREE.MeshLambertMaterial({ color: color });
  const mesh     = new THREE.Mesh(geometry, material);

  if (position) {
    mesh.position.set(...to3Array(position));
  }

  return mesh;
};
