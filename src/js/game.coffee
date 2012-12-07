require.config
    shim:
        'lib/three':   'exports': 'THREE'
        'lib/tween':   'exports': 'TWEEN'
        'lib/jquery':  'exports': '$'

requirejs [
    
    'lib/jquery'
    'lib/stim'
    'face'
    'score'
    'snake'
    'utils'
    'graphics3'
    'detector'
    'constants'

], ($, Stim, Face, Score, Snake, Utils, Graphics3, Detector, Const) ->

    class Game

        constructor: (container) ->

            @_steps = 0
            @_playing = false

            @_edible =
                food: new Stim.Map()
                poison: new Stim.Map()

            @_buildCube()
            @_makeGraph()

            @_score = new Score container
            @_snake = new Snake @_faces, @_edible, @_score
            @_graphics = new Graphics3 @_getFaces(), container

            @_setupControls()

            # $(window).keydown (event) =>
            #     if event.which is 69
            #         @step()
            #         @_steps += 4
            
        run: ->

            requestAnimationFrame => @step() and @run()

        step: ->

            if (@_steps % 5) is 0

                if @_snake.moves.isEmpty() and not @_playing

                    @_snake.moves = @_getFoodPath()

                @_snake.move()

            @_dropFood() if (@_steps % 100) is 0 or @_edible.food.isEmpty()
            @_graphics.show @_snake.head.face if @_snake.onNewFace()
            @_graphics.update()

            @_steps += 1

        # TODO: Don't use jQuery. Get a small library for controls
        _setupControls: ->

            $(window).keydown (event) =>

                if not @_playing and event.which in [37...40]

                    # TODO: Starting the game during this async call might
                    # cause problems. If it does, delay the action until we are
                    # at the start of step()
                    @_startGame()
                    @_playing = true

                switch event.which
                    when 37 then @_snake.turn 'left'
                    when 38 then @_snake.turn 'up'
                    when 39 then @_snake.turn 'right'
                    when 40 then @_snake.turn 'down'

        _startGame: ->

            @_snake.moves.clear()
            @_score.clear()
            @_snake.die()

            edibles = @_edible.food.values().concat @_edible.poison.values()
            edible.status = 'dead' for edible in edibles

            @_dropFood()

        _getFaces: -> face for key, face of @_faces

        _getFoodPath: ->

            time = new Date()

            return new Stim.Queue() unless @_edible.food.size
            
            targets = @_edible.food.values()
            squares = @_graph.aStar @_snake.head, targets..., (vertex) =>

                # TODO: Find a heuristic for a cube-based game world.
                # For now, use zero.
                0

            console.log new Date() - time

            @_graph.removeVertex @_snake.head

            new Stim.Queue squares

        _buildCube: ->

            @_faces = [
                new Face Const.normalX.clone()
                new Face Const.normalY.clone()
                new Face Const.normalZ.clone()
                new Face Const.normalNegX.clone()
                new Face Const.normalNegY.clone()
                new Face Const.normalNegZ.clone()
            ]
            
            for face, index in @_faces
                face.connect otherFace for otherFace in @_faces[index..]

        _dropFood: ->

            type = if (Utils.randInt 0, 5) is 0 then 'poison' else 'food'

            index = Utils.randInt 0, @_graph.vertices.size - 1
            square = @_graph.vertices.keys()[index]
            square.on type

            @_edible[type]?.set square

        # Do a depth-first search of the cube squares, building a data
        # structure meant for passing to the graph module.
        _makeGraph: ->
            
            @_graph = new Stim.Graph()

            explored = {}
            current = @_faces[0].squares[0][0]

            # Use an explicit stack rather than recursion just because.
            searchStack = [current]

            while searchStack.length

                current = searchStack.pop()
                current.graph = @_graph

                explored[current] = true
                @_graph.addVertex current

                for key, vertex of current.neighbours when not explored[vertex]

                    searchStack.push vertex

    container = document.getElementById 'game'

    detector = new Detector()
    unless detector.webgl

        detector.showWebGLError container
        return

    new Game(container).run()
