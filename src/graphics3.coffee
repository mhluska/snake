define ['lib/Three.js', 'src/constants', 'src/utils'], (THREE, Const, Utils) ->

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

        show: (nextFace) ->
            
            return if nextFace is @_targetFace

            face = @_targetFace
            @_targetFace = nextFace

            indepAxis = face.normal
            direction = face.directionTo nextFace

            timeSteps = 0
            totalTimeSteps = 30

            @_cameraMoveCallback = =>

                return @_cameraMoveCallback = null if timeSteps is totalTimeSteps

                @_orientCamera face, nextFace if timeSteps is (totalTimeSteps / 2)

                @_camera.position[nextFace.normal] = @_cameraHeight indepAxis

                increment = Const.cameraFaceOffset / totalTimeSteps
                increment *= -1 unless face.offset

                @_camera.position[indepAxis] -= increment
                @_camera.lookAt @_cube.position

                timeSteps += 1

        _orientCamera: (face, nextFace) ->

            nextUnitNormal = new THREE.Vector3 nextFace.up()...
            currentUnitNormal = new THREE.Vector3 face.up()...
            if @_camera.up.equals nextUnitNormal
                @_camera.up = currentUnitNormal.negate()
                
            else if @_camera.up.clone().negate().equals nextUnitNormal
                @_camera.up = currentUnitNormal

        _positionAboveFace: (face) ->

            normal = new THREE.Vector3 face.up()...
            normal.multiplyScalar Const.cameraFaceOffset

        _cameraHeight: (axis) ->

            height = @_bezier @_cos @_camera.position[axis]
            if @_targetFace.offset then height else -height

        _cos: (val) ->

            Const.cameraFaceOffset * Math.cos((val * Math.PI / 2) / Const.cameraFaceOffset)

        _bezier: (val) ->

            val

        _setupCamera: (ratio) ->

            @_camera = new THREE.PerspectiveCamera 75, ratio, 50, 10000
            @_targetFace = @_faces[Const.startFaceIndex]
            @_camera.position = @_positionAboveFace @_targetFace
            @_camera.lookAt @_cube.position
            @_scene.add @_camera

            window.camera = @_camera

        _buildScene: ->

            @_scene = new THREE.Scene()

            geometry = new THREE.CubeGeometry Const.cubeSize, Const.cubeSize,
                Const.cubeSize
            material = new THREE.MeshLambertMaterial color: 0x7198F5
            @_cube = new THREE.Mesh geometry, material
            @_scene.add @_cube

            # TODO: Make this more cross-browser without bringing in jQuery
            sceneWidth = @_container.offsetWidth
            sceneHeight = @_container.offsetHeight
            @_setupCamera sceneWidth / sceneHeight

            @_scene.add(new THREE.AxisHelper())

            light1 = new THREE.PointLight 0xffffff
            light1.position.set 500, 500, 500
            @_scene.add light1

            light2 = new THREE.PointLight 0xffffff
            light2.position.set -500, -500, -500
            @_scene.add light2

            @_renderer = new THREE.CanvasRenderer antialias: true
            @_renderer.setSize sceneWidth, sceneHeight

            @_container.appendChild @_renderer.domElement

        _buildNode: (x, y, z) ->

            geometry = new THREE.CubeGeometry Const.squareSize, Const.squareSize,
                Const.squareSize

            material = new THREE.MeshLambertMaterial color: 0x437f16
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


