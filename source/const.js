let constants = {
  CAMERA_DISTANCE: 500,
  FACES:           6,
  GAME_SIZE:       16,
  MESH_SIZE:       200,
  DEBUG:           false
};

constants.TILE_SIZE = constants.MESH_SIZE / constants.GAME_SIZE;

module.exports = constants;
