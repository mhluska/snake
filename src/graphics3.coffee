define ['lib/Three.js', 'src/constants'], (THREE, Const) ->

    class Graphics3

        constructor: (@_faces, @_container) ->

            @_cameraMoveCallback = null
            @_buildScene()

        update: ->
            
            for face in @_faces
                for column in face.squares
                    for square in column
                        @_updateCube square

            @_cameraMoveCallback?()
            @_renderer.render @_scene, @_camera

        show: (face) ->
            
            return if face is @_targetFace

            newPosition = new THREE.Vector3 face.positionFromCentroid()...
            indepAxis = @_targetFace.normal

            timeSteps = 0
            totalTimeSteps = 30

            currentFaceOffset = @_targetFace.offset
            @_targetFace = face

            @_cameraMoveCallback = =>

                return @_cameraMoveCallback = null if timeSteps is totalTimeSteps

                @_camera.position[face.normal] = @_cameraHeight indepAxis

                @_camera.lookAt @_cube.position

                increment = Const.cameraFaceOffset / totalTimeSteps
                increment *= -1 unless currentFaceOffset

                @_camera.position[indepAxis] -= increment
                @_renderer.render @_scene, @_camera

                timeSteps += 1

        _cameraHeight: (axis) ->

            console.log "f(#{@_camera.position[axis]}) = #{@_bezier @_cos @_camera.position[axis]}"
            height = @_bezier @_cos @_camera.position[axis]
            if @_targetFace.offset then height else -height

        _cos: (val) ->

            Const.cameraFaceOffset * Math.cos((val * Math.PI / 2) / Const.cameraFaceOffset)

        _bezier: (val) ->

            val

        _setupCamera: (ratio) ->

            # TODO: Specify camera rotation. It won't be oriented properly if
            # startFaceIndex isn't 2.
            
            @_camera = new THREE.PerspectiveCamera 75, ratio, 50, 10000
            @_targetFace = @_faces[Const.startFaceIndex]
            @_camera.position = new THREE.Vector3 @_targetFace.positionFromCentroid()...
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


