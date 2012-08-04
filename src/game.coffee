define ['src/face'], (Face) ->
    
    class Game

        constructor: ->

            @_buildCube()

            console.log 'constructed'
            window.game = @

        run: ->

        _buildCube: ->

            @cubeFaces = []

            @cubeFaces.push new Face x: true
            @cubeFaces.push new Face y: true
            @cubeFaces.push new Face z: true
            @cubeFaces.push new Face x: null
            @cubeFaces.push new Face y: null
            @cubeFaces.push new Face z: null

            console.log @cubeFaces[0].squares[0][6]
