define [
    
    'lib/Three.js'
    'lib/Tween.js'
    'src/queue'
    'src/constants'
    'src/utils'

    ], (THREE, TWEEN, Queue, Const, Utils) ->

    class Graphics3

        constructor: (@_faces, @_container) ->

            @_objects = new Queue

            # A square can have multiple items but only one is shown. This is 
            # the order of precedence.
            @_itemOrder = ['poison', 'food', 'snake']

            @_squareTweens =
                poisoned: {}
                dead: {}

            @_cameraMoveCallback = null
            @_buildScene()

        update: ->
            
            for face in @_faces
                for column in face.squares
                    for square in column
                        @_updateSquare square

            TWEEN.update()
            @_renderer.render @_scene, @_camera

        show: (nextFace) ->
            
            return if nextFace is @_targetFace

            face = @_targetFace
            @_targetFace = nextFace

            start = @_camera.position[face.axis]
            obj = x: start

            @_cameraTween?.update(Date.now() + Const.cameraMoveSpeed)
            @_cameraTween?.stop()

            @_cameraTween = new TWEEN.Tween(obj)
                .to({ x: 0 }, Const.cameraMoveSpeed)
                .easing(TWEEN.Easing.Quartic.Out)
                .onUpdate =>
                    @_camera.position[nextFace.axis] = @_cos obj.x
                    @_camera.position[nextFace.axis] *= @_targetFace.normal[@_targetFace.axis]
                    @_camera.position[face.axis] = obj.x
                    @_camera.lookAt @_cube.position

                    @_orientCamera(face, nextFace) if obj.x > start / 2

                .start()

        _cos: (val) ->

            Const.cameraFaceOffset * Math.cos((val * Math.PI / 2) / Const.cameraFaceOffset)

        _orientCamera: (face, nextFace) ->

            oldCameraUp = @_camera.up.clone()

            if Utils.getAxis(@_camera.up) is nextFace.axis
                @_camera.up.copy face.normal

            @_camera.up.negate() if oldCameraUp.equals nextFace.normal

        _positionAboveFace: (face) ->

            face.normal.clone().multiplyScalar Const.cameraFaceOffset

        _setupCamera: (ratio) ->

            @_camera = new THREE.PerspectiveCamera 75, ratio, 50, 10000
            @_targetFace = @_faces[Const.startFaceIndex]
            @_camera.position = @_positionAboveFace @_targetFace
            @_camera.lookAt @_cube.position
            @_scene.add @_camera

        _buildScene: ->

            @_scene = new THREE.Scene()

            geometry = new THREE.CubeGeometry Const.cubeSize, Const.cubeSize,
                Const.cubeSize
            material = new THREE.MeshLambertMaterial color: 0xA5C9F3
            @_cube = new THREE.Mesh geometry, material
            @_scene.add @_cube

            # TODO: Make this more cross-browser without bringing in jQuery
            sceneWidth = @_container.offsetWidth
            sceneHeight = @_container.offsetHeight
            @_setupCamera sceneWidth / sceneHeight

            light1 = new THREE.PointLight 0xffffff
            light1.position.set 500, 500, 500
            @_scene.add light1

            light2 = new THREE.PointLight 0xffffff
            light2.position.set -500, -500, -500
            @_scene.add light2

            @_renderer = new THREE.WebGLRenderer
            @_renderer.setSize sceneWidth, sceneHeight

            @_container.appendChild @_renderer.domElement

        _buildObject: ->

            geometry = new THREE.CubeGeometry Const.squareSize, Const.squareSize,
                Const.squareSize

            material = new THREE.MeshLambertMaterial transparent: true
            mesh = new THREE.Mesh geometry, material
            @_scene.add mesh

            mesh

        _updateSquare: (square) ->

            switch square.status

                when 'on'

                    mesh = square.node or @_objects.dequeue() or @_buildObject()
                    mesh.position.copy square.position
                    mesh.material.opacity = 1
                    mesh.visible = true

                    square.node = mesh

                    @_updateItems square, mesh

                when 'dead'

                    self = @

                    node = square.node
                    square.node = null

                    @_squareTweens.dead[square] ?= new TWEEN.Tween(opacity: 1)
                        .to({ opacity: 0 }, 1000)
                        .easing(TWEEN.Easing.Quartic.Out)
                        .onUpdate ->
                            node.material.opacity = @opacity
                        .onComplete ->
                            square.off() if square.status is 'dead'
                            self._recycleNode node
                            self._squareTweens.dead[square] = null

                        .start()

                when 'off'

                    @_recycleNode square.node
                    square.node = null

                when 'poisoned'

                    return if @_squareTweens.poisoned[square]

                    colour = square.node.material.color

                    newColour = {}
                    for additive in ['r', 'g', 'b']
                        newColour[additive] = Math.max(0.25, colour[additive] * 0.75)

                    self = @
                    @_squareTweens.poisoned[square] = new TWEEN.Tween(colour)
                        .to(newColour, 200)
                        .easing(TWEEN.Easing.Linear.None)
                        .onComplete ->
                            self._squareTweens.poisoned[square] = null

                        .start()

        _recycleNode: (node) ->

            return unless node

            @_objects.enqueue node
            node.visible = false

        _updateItems: (square, mesh) ->

            for drawItem in @_itemOrder
                if square.item is drawItem
                    colour = new THREE.Color Const.colours[drawItem]
                    square.node.material.color = colour
                    return

