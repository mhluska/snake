class SnakeDeathError extends Error {
  constructor({ message = '', snake } = {}) {
    super(message);
    this.snake = snake;
    this.message = message;
    this.name = 'SnakeDeathError';
  }
}

module.exports = {
  SnakeDeathError: SnakeDeathError
};
