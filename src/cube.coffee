define [
    
    'src/grid'
    'src/graph'
    'src/utils'
    'src/world'

    ], (Grid, Graph, Utils, World) ->

    class Cube extends World

        constructor: (@game, length = 15) ->

            @squaresX = @squaresY = length

            @_faces = (new Grid(game, length, length) for index in [0..5])

            # Create a graph to model face connections
            # TODO: Possibly don't need this
            @cubeGraph = new Graph [

                [@_faces[2], @_faces[0]]
                [@_faces[2], @_faces[1]]
                [@_faces[2], @_faces[3]]
                [@_faces[2], @_faces[5]]
                [@_faces[3], @_faces[4]]
            ]

        # Define directions for traversing the cube
        _adjacentFaces: do ->

            # orientation maps the start index to neighbouring face indices
            # startIndex: [up, right, down, left]
            orientation =

                0: [4, 3, 2, 1]
                1: [0, 2, 5, 4]
                2: [0, 3, 5, 1]
                3: [0, 4, 5, 2]
                4: [0, 1, 5, 3]
                5: [2, 3, 4, 1]

            (index) ->

                neighbours = orientation[index]

                'up':    neighbours[0]
                'right': neighbours[1]
                'down':  neighbours[2]
                'left':  neighbours[3]

        registerSquareAt: ->

        dropFood: ->

            # Drop the food on a random face
            index = Utils.randInt 0, 5
            @_faces[index].dropFood()

        # Refer to Grid.squareAt for definition.
        squareAt: (pos, type, value) ->

            @_faces[pos.faceIndex].squareAt pos, type, value

        makeWorld: ->

            grid.makeWorld() for grid in @_faces

        moduloBoundaries: (pair) ->

            pair = super pair
            pair.faceIndex =

                # The snake can move in only one direction at a time, so at most
                # one of these cases will be true:
                if pair.y < 0
                    @_adjacentFaces(pair.faceIndex).up

                else if pair.x > @length
                    @_adjacentFaces(pair.faceIndex).right

                else if pair.y > @length
                    @_adjacentFaces(pair.faceIndex).down

                else if pair.x < 0
                    @_adjacentFaces(pair.faceIndex).left

                else pair.faceIndex

            pair
