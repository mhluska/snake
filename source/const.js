let constants = {
  CAMERA_DISTANCE: 500,
  GAME_SIZE:       16,
  MESH_SIZE:       200,
  DEBUG:           false,
  Colors: {
    FOOD: 0x7fdc50,
    WORLD: 0xa5c9f3,
    LIGHT: 0xffffff,
    SNAKE: 0x9586de,
    DEBUG_SNAKE: 0xeb3b3b,
    DEBUG_PATH: 0xf2ff9e
  }
};

constants.TILE_SIZE = constants.MESH_SIZE / constants.GAME_SIZE;

module.exports = constants;
