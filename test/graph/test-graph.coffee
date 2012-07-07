'import utils'
'import graph'

class window.TestGraph extends Test

    runDijkstras: (edges, start, ends, expected, message = null) ->

        graph = new Game.Graph edges

        dijkstras = graph.dijkstras start, ends...
        @show dijkstras, "Result of Dijkstra's algorithm:"
        @assert @equals(dijkstras, expected), message

    testGraphDetails: ->

        edgeWeights = [
            ['a', 'b', 2]
            ['a', 'c', 8]
            ['a', 'd', 20]
            ['d', 'c', 9]
            ['c', 'f', 1]
            ['d', 'f', 1]
            ['e', 'e', 0]
        ]

        @show edgeWeights, "Edge weights:"

        graph = new Game.Graph edgeWeights

        @show graph._neighbours, "Internal neighbours object:"
        @show graph.vertices(), 'Vertices:'
        @show graph._distanceBetween, 'Internal distanceBetween object:'

        distance = graph.distanceBetween graph.vertices()[0], graph.vertices()[1]
        @show distance, 'Distance between vertices a and b:'

    testDijkstrasWithWeights: ->

        edgeWeights = [
            ['a', 'b', 2]
            ['a', 'c', 8]
            ['a', 'd', 20]
            ['d', 'c', 9]
            ['c', 'f', 1]
            ['d', 'f', 1]
            ['e', 'e', 0]
        ]

        message = "Shortest path from 'a' to 'd'"
        @runDijkstras edgeWeights, 'a', 'd', ['c', 'f', 'd'], message

    testDijkstrasWithoutWeights: ->

        edges = [
            ['a', 'b']
            ['a', 'c']
            ['a', 'd']
            ['d', 'c']
            ['c', 'f']
            ['d', 'f']
            ['e', 'e']
        ]

        message = "Shortest path from 'a' to 'd' in a weightless graph."
        @runDijkstras edges, 'a', 'd', ['d'], message

    testDijkstrasWithDuplicateEdges: ->

        edgeWeights = [
            ['a', 'b', 2]
            ['a', 'b', 2]
            ['a', 'b', 2]
            ['a', 'b', 2]
            ['a', 'b', 2]
            ['a', 'c', 8]
            ['a', 'd', 20]
            ['a', 'd', 20]
            ['a', 'd', 20]
            ['d', 'c', 9]
            ['c', 'f', 1]
            ['c', 'f', 1]
            ['d', 'f', 1]
            ['d', 'f', 1]
            ['d', 'f', 1]
            ['e', 'e', 0]
            ['e', 'e', 0]
        ]

        message = "Shortest path from 'a' to 'd' with duplicate edges."
        @runDijkstras edgeWeights, 'a', 'd', ['c', 'f', 'd'], message

    testDijkstrasWithMultipleTargets: ->

        edgeWeights = [
            ['a', 'b', 2]
            ['a', 'c', 8]
            ['a', 'd', 20]
            ['d', 'c', 9]
            ['c', 'f', 1]
            ['d', 'f', 1]
            ['e', 'e', 0]
        ]

        message = "Shortest path from 'a' to 'c', 'd', or 'f'."
        @runDijkstras edgeWeights, 'a', ['c', 'd', 'f', 'b'], ['b'], message
