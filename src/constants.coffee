define ['src/vector3'], (Vector3) ->

    class Constants

        @squareSize: 16
        @squareCount: 15
        @cubeSize: @squareSize * @squareCount
        @startFaceIndex: 2

        @cameraOffset: 300
        @cameraFaceOffset: @cameraOffset + (@cubeSize / 2)

        @normalX: new Vector3(1, 0, 0)
        @normalY: new Vector3(0, 1, 0)
        @normalZ: new Vector3(0, 0, 1)
        @normalNegX: new Vector3(-1, 0, 0)
        @normalNegY: new Vector3(0, -1, 0)
        @normalNegZ: new Vector3(0, 0, -1)
