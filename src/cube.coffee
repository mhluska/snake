define ['grid', 'graph'], (Grid, Graph) ->

    class Cube

        constructor: (@game, @length = 15) ->

            @faces = (new Grid(game, @length, @length) for index in [0..5])

            # Create a graph to model face connections
            @cubeGraph = new Graph [

                [@faces[2], @faces[0]]
                [@faces[2], @faces[1]]
                [@faces[2], @faces[3]]
                [@faces[2], @faces[5]]
                [@faces[3], @faces[4]]
            ]

        registerSquareAt: ->


