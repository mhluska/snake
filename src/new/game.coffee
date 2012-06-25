snake = new Game.Snake
graphics = new Game.Graphics
grid = new Game.Grid snake, graphics

run = ->
    snake.move()
    graphics.update()
    
setInterval run, 150
run()
