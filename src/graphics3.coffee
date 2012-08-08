define ['lib/Three.js', 'src/constants'], (THREE, Const) ->

    class Graphics3

        constructor: (@_faces, @_container) ->

            @_buildScene()

        update: ->
            
            for face in @_faces
                for column in face.squares
                    for square in column
                        @_updateCube square

            @_controls?.update @_clock.getDelta()
            @_renderer.render @_scene, @_camera

        show: (face) ->

            window.camera = @_camera

            newPosition = new THREE.Vector3 @_cameraOffset(face)...
            intervalId = null
            animation = =>

                @_camera.position[face.normal] = (Math.sin @_camera.position[@_targetFace.normal]) * Const.cameraOffset
                clearInterval intervalId if @_camera.position.equals newPosition

            setTimeout animation, 30
            animation()

            console.log 'showing new face:'
            console.log face

            @_targetFace = face

        _cameraOffset: (face) ->

            face.positionFromCentroid Const.cameraOffset

        _setupCamera: (ratio) ->

            # TODO: Specify camera rotation. It won't be oriented properly if
            # startFaceIndex isn't 2.
            
            @_camera = new THREE.PerspectiveCamera 75, ratio, 50, 10000
            @_targetFace = @_faces[Const.startFaceIndex]
            @_camera.position.set @_cameraOffset(@_targetFace)...
            @_camera.lookAt @_cube.position
            @_scene.add @_camera

            window.camera = @_camera

        _buildScene: ->

            @_scene = new THREE.Scene()

            geometry = new THREE.CubeGeometry Const.cubeSize, Const.cubeSize,
                Const.cubeSize
            material = new THREE.MeshLambertMaterial color: 0xcccccc
            @_cube = new THREE.Mesh geometry, material
            @_scene.add @_cube

            # TODO: Make this more cross-browser without bringing in jQuery
            sceneWidth = @_container.offsetWidth
            sceneHeight = @_container.offsetHeight
            @_setupCamera sceneWidth / sceneHeight

            @_scene.add(new THREE.AxisHelper())

            @_clock = new THREE.Clock()
            # @_controls = new THREE.FlyControls @_camera
            # @_controls.movementSpeed = 1000
            # @_controls.domElement = @_container
            # @_controls.rollSpeed = Math.PI / 12
            # @_controls.autoForward = false
            # @_controls.dragToLook = false

            light = new THREE.PointLight 0xffffff
            light.position.set 300, 600, 600
            @_scene.add light

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


