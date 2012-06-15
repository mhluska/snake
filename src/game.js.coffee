snake = new Game.Snake
grid = new Game.Grid snake
       
run = ->
    snake.move()
    grid.update()
    console.log 'yo'
    
setInterval run, 150
run()
