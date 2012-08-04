define ->

    class Graphics

        update: ->

            @grid.eachSquare (pos, square) =>

                for type, piece of square
                    
                    if @_awaitingShow piece
                        piece.node = @_drawPiece(pos, type) unless piece.exists()
                        @_showPiece piece

                    @_hidePiece(piece) if @_awaitingHide piece
