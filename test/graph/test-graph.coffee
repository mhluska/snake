'import graph'

class TestGraph extends Test

    run: do (@) =>

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
        @assert graph._neighbours['a'].length is 3, "Vertex a has 3 neighbours"

        @show graph.vertices(), 'Vertices:'

        @show graph._distanceBetween, 'Internal distanceBetween object:'

        distance = graph.distanceBetween graph.vertices()[0], graph.vertices()[1]
        @show distance, 'Distance between vertices a and b:'

        dijkstras = graph.dijkstras 'a', 'd'
        @show dijkstras, "Result of Dijkstra's algorithm:"
        @assert @equals(dijkstras, ['c', 'f', 'd']), "Shortest path from 'a' to 'd'"
