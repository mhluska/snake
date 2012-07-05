'import graph'

class window.TestGraph extends Test

    before: ->
        
        @edgeWeights = [
            ['a', 'b', 2]
            ['a', 'c', 8]
            ['a', 'd', 20]
            ['d', 'c', 9]
            ['c', 'f', 1]
            ['d', 'f', 1]
            ['e', 'e', 0]
        ]

        @edges = [
            ['a', 'b']
            ['a', 'c']
            ['a', 'd']
            ['d', 'c']
            ['c', 'f']
            ['d', 'f']
            ['e', 'e']
        ]

    testGraphDetails: ->

        @show @edgeWeights, "Edge weights:"

        graph = new Game.Graph @edgeWeights

        @show graph._neighbours, "Internal neighbours object:"
        @show graph.vertices(), 'Vertices:'
        @show graph._distanceBetween, 'Internal distanceBetween object:'

        distance = graph.distanceBetween graph.vertices()[0], graph.vertices()[1]
        @show distance, 'Distance between vertices a and b:'

    testDijkstrasWithWeights: ->

        graph = new Game.Graph @edgeWeights

        dijkstras = graph.dijkstras 'a', 'd'
        @show dijkstras, "Result of Dijkstra's algorithm:"
        @assert @equals(dijkstras, ['c', 'f', 'd']), "Shortest path from 'a' to 'd'"

    testDijkstrasWithoutWeights: ->

        weightlessGraph = new Game.Graph @edges

        weightlessDijkstras = weightlessGraph.dijkstras 'a', 'd'
        @show weightlessDijkstras, "Result of weightless Dijkstra's algorithm:"
        equal = @equals weightlessDijkstras, ['c', 'f', 'd']
        @assert equal, "Shortest path from 'a' to 'd' in a weightless graph."

