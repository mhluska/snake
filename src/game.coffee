define ['src/face'], (Face) ->
    
    class Game

        constructor: ->

            @_buildCube()

            console.log 'constructed'
            window.game = @

        run: ->

        _buildCube: ->

            @cubeFaces = []

            @cubeFaces.push new Face 'x', true
            @cubeFaces.push new Face 'y', true
            @cubeFaces.push new Face 'z', true
            @cubeFaces.push new Face 'x'
            @cubeFaces.push new Face 'y'
            @cubeFaces.push new Face 'z'

            for face, index in @cubeFaces
                for otherFace, index2 in @cubeFaces when index2 > index
                    face.connect otherFace
