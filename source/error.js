class SnakeDeathError extends Error {
  constructor(message) {
    super(message);
    this.message = message;
    this.name = 'SnakeDeathError';
  }
}

module.exports = {
  SnakeDeathError: SnakeDeathError
};
