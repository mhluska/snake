define ['jquery', 'src/graphics'], ($, Graphics) ->

    class Graphics2 extends Graphics

        constructor: (@game, @grid, @gridNode) ->

            super @game

            @_buildDom()

        _buildDom: (gridNode) ->

            @gridNode.css
                width: @grid.squareWidth * @grid.squaresX
                height: @grid.squareHeight * @grid.squaresY

            $('body').prepend @gridNode

        _buildDomNode: (pos, type) ->

            node = $("<div class='#{type}'></div>")
            node.css
                width: @grid.squareWidth
                height: @grid.squareHeight

            node.hide()

        _setNodePosition: (node, pos) ->

            node.css
                top: pos.y * @grid.squareHeight
                left: pos.x * @grid.squareWidth

        _awaitingShow: (piece) ->

            piece.visible() and not $(piece.node).is ':visible'

        _awaitingHide: (piece) ->

            piece.hidden() and $(piece.node).is ':visible'

        _makeNode: (pos, type) ->

            node = @_buildDomNode pos, type
            @gridNode.append node
            @_setNodePosition node, pos

        update: ->

            @grid.eachSquare (pos, square) =>

                for type, piece of square
                    
                    if @_awaitingShow piece
                        piece.node = @_makeNode(pos, type) unless piece.exists()
                        $(piece.node).show()

                    $(piece.node).hide() if @_awaitingHide piece
