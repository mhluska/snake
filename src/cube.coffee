define ['grid', 'graph', 'utils'], (Grid, Graph, Utils) ->

    class Cube

        constructor: (@game, @length = 15) ->

            @faces = (new Grid(game, @length, @length) for index in [0..5])
            @maxFood = 24

            # Create a graph to model face connections
            @cubeGraph = new Graph [

                [@faces[2], @faces[0]]
                [@faces[2], @faces[1]]
                [@faces[2], @faces[3]]
                [@faces[2], @faces[5]]
                [@faces[3], @faces[4]]
            ]

        registerSquareAt: ->

        dropFood: ->

            # Drop the food on a random face
            index = Utils.randInt 0, 5
            @faces[index].dropFood()
