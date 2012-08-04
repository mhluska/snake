define [
    
    'src/grid'
    'src/graph'
    'src/utils'
    'src/world'

    ], (Grid, Graph, Utils, World) ->

    class Cube extends World

        constructor: (@game, squares = 15) ->

            @squaresX = @squaresY = squares

            # TODO: Change this so that the user provides a cube dimension and
            # the square size is hard coded. SquaresX and squaresY will be 
            # calculated.
            @squareSize = 15

            @_faces = (new Grid(game, squares, squares) for index in [0..5])

        # Define directions for traversing the cube
        _adjacentFaces: do ->

            # orientation maps the start index to neighbouring face indices
            # startIndex: [up, right, down, left]
            orientation =

                0: [2, 3, 4, 1]
                1: [4, 0, 2, 5]
                2: [1, 5, 3, 0]
                3: [2, 5, 5, 2]
                4: [3, 5, 0, 1]
                5: [2, 1, 4, 3]

            (index) ->

                neighbours = orientation[index]

                'up':    neighbours[2]
                'right': neighbours[1]
                'down':  neighbours[0]
                'left':  neighbours[3]

        eachSquare: (callback) ->

            for grid, index in @_faces
                return false if false is grid.eachSquare callback, index

        dropFood: ->

            # Drop the food on a random face
            index = Utils.randInt 0, 5
            @_faces[index].dropFood()

        # Refer to Grid.squareAt for definition.
        squareAt: (pos, type, value) ->

            @_faces[pos.faceIndex].squareAt pos, type, value

        toGraph: ->

        makeWorld: ->

            grid.makeWorld() for grid in @_faces

        moduloBoundaries: (pair) ->

            pair.faceIndex =

                # The snake can move in only one direction at a time, so at most
                # one of these cases will be true:
                if pair.y < 0
                    @_adjacentFaces(pair.faceIndex).down

                else if pair.x >= @squaresX
                    @_adjacentFaces(pair.faceIndex).right

                else if pair.y >= @squaresY
                    @_adjacentFaces(pair.faceIndex).up

                else if pair.x < 0
                    @_adjacentFaces(pair.faceIndex).left

                else pair.faceIndex

            super pair
