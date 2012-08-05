define ['lib/Three.js'], (THREE) ->

    class Graphics3

        constructor: (@faces) ->

        update: ->
            
            for face in @faces
                for column in face.squares
                    for square in column
                        'no-op'
