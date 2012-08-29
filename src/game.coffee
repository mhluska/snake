require.config
    paths:
        'jquery': 'lib/jquery'

    shim:
        'lib/Three.js': 'exports': 'THREE'
        'lib/Tween.js': 'exports': 'TWEEN'

define [
    
    'jquery'
    'src/face'
    'src/score'
    'src/snake'
    'src/queue'
    'src/hashmap'
    'src/utils'
    'src/graph'
    'src/graphics3'
    'src/constants'

    ], ($, Face, Score, Snake, Queue, HashMap, Utils, Graph, Graphics3, Const) ->
    
    class Game

        constructor: (container) ->

            @_steps = 0
            @_playing = true
            @_food = new HashMap

            @_buildCube()
            @_makeGraph()

            @_snake = new Snake @_faces, @_food, new Score container
            @_graphics = new Graphics3 @_getFaces(), container

            @_setupControls()

            $(window).keydown (event) =>
                if event.which is 69
                    @step()
                    @_steps += 4
            
        run: ->

            return
            requestAnimationFrame => @step() and @run()

        step: ->

            if (@_steps % 5) is 0

                if @_snake.moves.isEmpty() and not @_playing
                    @_snake.moves = @_getFoodPath()

                @_snake.move()

            @_dropFood() if (@_steps % 100) is 0 or @_food.isEmpty()
            @_graphics.show @_snake.head.face if @_snake.onNewFace()
            @_graphics.update()

            @_steps += 1

        # TODO: Don't use jQuery. Get a small library for controls
        _setupControls: ->

            $(window).keydown (event) =>

                # TODO: Get player controls working with AI.
                switch event.which
                    when 37 then @_snake.turn 'left'
                    when 38 then @_snake.turn 'up'
                    when 39 then @_snake.turn 'right'
                    when 40 then @_snake.turn 'down'
                    else return

        _getFaces: -> face for key, face of @_faces

        _getFoodPath: ->

            time = Date.now()
            @_graph.addVertex @_snake.head
            squares = @_graph.dijkstras @_snake.head, @_food.values()...
            @_graph.removeVertex @_snake.head

            new Queue squares

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

            @_food.put square if type is 'food'

        # Do a depth-first search of the cube squares, building a data
        # structure meant for passing to the graph module.
        _makeGraph: ->
            
            @_graph = new Graph

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
