define ['jquery', 'src/graphics'], ($, Graphics) ->

    class Graphics2 extends Graphics

        constructor: (@game, @grid, @gridNode) ->

            @_buildDom()

        _buildDom: (gridNode) ->

            @gridNode.css
                width: @grid.squareWidth * @grid.squaresX
                height: @grid.squareHeight * @grid.squaresY

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

        _showPiece: (piece) -> $(piece.node).show()

        _hidePiece: (piece) -> $(piece.node).hide()

        _drawPiece: (pos, type) ->

            node = @_buildDomNode pos, type
            @gridNode.append node
            @_setNodePosition node, pos
