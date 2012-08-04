define ['src/graphics', 'lib/Three.js'], (Graphics, THREE) ->

    class Graphics3 extends Graphics

        constructor: (@game, @grid, @wrapperNode) ->

            @_buildScene()

        _buildScene: ->

            @scene = new THREE.Scene()

            ratio = window.innerWidth / window.innerHeight
            @camera = new THREE.PerspectiveCamera 75, ratio, 1, 10000
            @camera.position.z = 450
            @camera.position.x = 250
            @camera.position.y = 300

            @scene.add @camera

            @cubeSize = @grid.squareSize * @grid.squaresX
            geometry = new THREE.CubeGeometry @cubeSize, @cubeSize, @cubeSize
            material = new THREE.MeshBasicMaterial color: 0xff0000, wireframe: true
            mesh = new THREE.Mesh geometry, material

            @scene.add mesh

            @camera.lookAt mesh.position

            @renderer = new THREE.CanvasRenderer()
            @renderer.setSize window.innerWidth, window.innerHeight

            @wrapperNode.appendChild @renderer.domElement

            @renderer.render @scene, @camera

        _awaitingShow: (piece) ->

            return piece.visible() unless piece.exists()

            piece.visible() and piece.node.geometry.opacity is 0

        _awaitingHide: (piece) ->

            return false unless piece.exists()

            piece.hidden() and piece.node.geometry.opacity isnt 0

        _showPiece: (piece) ->

        _hidePiece: (piece) ->

        _drawPiece: (pos, type) ->

            geometry = new THREE.CubeGeometry @grid.squareSize, @grid.squareSize,
                @grid.squareSize

            material = new THREE.MeshBasicMaterial color: 0xff0000
            mesh = new THREE.Mesh geometry, material

            pos.x *= @grid.squareSize
            pos.y *= -@grid.squareSize

            if @game.snake.direction in ['down', 'up']
                switch pos.faceIndex
                    when 0 then mesh.position.set pos.x, pos.y, @cubeSize
                    when 1 then mesh.position.set 0, -@cubeSize - pos.y, @cubeSize - pos.x
                    when 2 then mesh.position.set -pos.y, 0, @cubeSize - pos.x
                    when 3 then mesh.position.set @cubeSize, pos.y, @cubeSize - pos.x
                    when 4 then mesh.position.set pos.x, -@cubeSize, @cubeSize + pos.y
                    when 5 then mesh.position.set @cubeSize - pos.x, pos.y, 0
            else
                switch pos.faceIndex
                    when 0 then mesh.position.set pos.x, pos.y, @cubeSize
                    when 1 then mesh.position.set 0, -@cubeSize - pos.y, @cubeSize - pos.x
                    when 2 then mesh.position.set -pos.y, 0, @cubeSize - pos.x
                    when 3 then mesh.position.set @cubeSize, pos.y, @cubeSize - pos.x
                    when 4 then mesh.position.set pos.y + @cubeSize, -@cubeSize, @cubeSize - pos.x
                    when 5 then mesh.position.set @cubeSize - pos.x, pos.y, 0
            

            @scene.add mesh

        update: ->
            super()
            @renderer.render @scene, @camera
