const constants = {
  DEBUG:           false,
  CAMERA_DISTANCE: 450,
  GAME_SIZE:       16,
  MESH_SIZE:       200,
  FOOD_START:      16,
  Colors: {
    FOOD: 0xee7f5e,
    WORLD: 0x00bdd1,
    LIGHT: 0xffffff,
    SNAKE: 0x885f4d,
    ENEMY: 0xc97373,
    EYES:  0x8c7c50,
    DEBUG_SNAKE: 0xeb3b3b,
    DEBUG_PATH: 0xf2ff9e
  }
};

constants.TILE_SIZE = constants.MESH_SIZE / constants.GAME_SIZE;

module.exports = constants;
