snake = new Game.Snake
grid = new Game.Grid snake
graphics = new Game.Graphics grid

run = ->
    snake.move()
    graphics.update()
    
setInterval run, 150
run()
