define ['grid', 'graph', 'utils', 'world'], (Grid, Graph, Utils, World) ->

    class Cube extends World

        constructor: (@game, @length = 15) ->

            @_world = (new Grid(game, @length, @length) for index in [0..5])

            # Create a graph to model face connections
            @cubeGraph = new Graph [

                [@_world[2], @_world[0]]
                [@_world[2], @_world[1]]
                [@_world[2], @_world[3]]
                [@_world[2], @_world[5]]
                [@_world[3], @_world[4]]
            ]

        registerSquareAt: ->

        dropFood: ->

            # Drop the food on a random face
            index = Utils.randInt 0, 5
            @_world[index].dropFood()

        # Refer to Grid.squareAt for definition.
        squareAt: (pos, type, value) ->

            @_world[pos.faceIndex].squareAt pos, type, value
