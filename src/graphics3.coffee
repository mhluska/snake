define ['lib/Three.js', 'src/constants'], (THREE, Const) ->

    class Graphics3

        constructor: (@_faces, @_container) ->

            @_buildScene()

        update: ->
            
            for face in @_faces
                for column in face.squares
                    for square in column
                        @_updateCube square

            @_renderer.render @_scene, @_camera

        _buildScene: ->

            @_scene = new THREE.Scene()

            # TODO: Make this more cross-browser without bringing in jQuery
            sceneWidth = @_container.offsetWidth
            sceneHeight = @_container.offsetHeight
            ratio = sceneWidth / sceneHeight

            @_camera = new THREE.PerspectiveCamera 75, ratio, 1, 10000
            @_camera.position.z = 450
            @_camera.position.x = 250
            @_camera.position.y = 300

            @_scene.add @_camera

            cubeSize = Const.squareCount * Const.squareSize
            geometry = new THREE.CubeGeometry cubeSize, cubeSize, cubeSize
            material = new THREE.MeshBasicMaterial color: 0xff0000, wireframe: true
            mesh = new THREE.Mesh geometry, material
            @_scene.add mesh

            @_camera.lookAt mesh.position

            @_renderer = new THREE.CanvasRenderer()
            @_renderer.setSize sceneWidth, sceneHeight

            @_container.appendChild @_renderer.domElement

        _buildNode: (x, y, z) ->

            geometry = new THREE.CubeGeometry Const.squareSize, Const.squareSize,
                Const.squareSize

            material = new THREE.MeshBasicMaterial color: 0xff0000, transparent: true
            mesh = new THREE.Mesh geometry, material
            mesh.position.set x, y, z
            @_scene.add mesh

            mesh

        _updateCube: (square) ->

            if square.status is 'on'

                square.node ?= @_buildNode square.x, square.y, square.z
                square.node.material.opacity = 1

            else if square.node

                square.node.material.opacity = 0


