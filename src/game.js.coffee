snake = new Game.Snake
grid = new Game.Grid snake
       
run = ->
    snake.move()
    grid.update()
    
setInterval run, 150
run()
