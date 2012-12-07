define [
    
    'lib/three'

], (THREE) ->

    class Constants

        @edgeWeight: 1
        @snakeMinLength: 3
        @snakeStartLength: 6
        @maxMoveQueueSize: 5

        @squareSize: 15
        @squareCount: 15
        @cubeSize: @squareSize * @squareCount
        @startFaceIndex: 2

        @cameraOffset: 300
        @cameraMoveSpeed: 750
        @cameraFaceOffset: @cameraOffset + (@cubeSize / 2)

        @normalX: new THREE.Vector3(1, 0, 0)
        @normalY: new THREE.Vector3(0, 1, 0)
        @normalZ: new THREE.Vector3(0, 0, 1)
        @normalNegX: new THREE.Vector3(-1, 0, 0)
        @normalNegY: new THREE.Vector3(0, -1, 0)
        @normalNegZ: new THREE.Vector3(0, 0, -1)

        @colours:
            'poison': 0x4F5A1D
            'food': 0x7FDC50
            'snake': 0x9586DE
