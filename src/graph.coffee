# Allows the snake AI to find shortest paths between food items

window.Game ?= {}
class Game.Graph
    # The constructor takes edge weights encoded as 3-arrays. Since we are 
    # working with undirected graphs, the ordering of the first two values does
    # not matter. The third value must be the edge weight. A disconnected
    # vertex 'v' gets a triplet of ['v', 'v', 0].
    # edgeWeights = [
    #   ['a', 'b', 2]
    #   ['a', 'c', 8]
    #   ['a', 'd', 20]
    #   ['d', 'c', 9]
    #   ['c', 'f', 1]
    #   ['d', 'f', 1]
    #   ['e', 'e', 0]
    # ]
    #
    # If the graph has no edge weights (or all equal weights), just pass pairs.
    # edgeWeights = [
    #   ['a', 'b']
    #   ['a', 'c']
    #   ...
    # ]
    constructor: (@edgeWeights = []) ->

        weightless = @_weightlessGraph()

        # Setup neighbour arrays and bi-directional distances between vertices
        @_distanceBetween = {}
        @_neighbours = {}
        for triple in @edgeWeights
            [vertex1, vertex2, weight] = triple
            
            weight = 1 if weightless

            @_distanceBetween[vertex1] ?= {}
            @_distanceBetween[vertex2] ?= {}
            @_distanceBetween[vertex1][vertex2] = weight
            @_distanceBetween[vertex2][vertex1] = weight

            @_neighbours[vertex1] ?= []
            @_neighbours[vertex2] ?= []
            unless vertex1 is vertex2
                @_neighbours[vertex1].push vertex2
                @_neighbours[vertex2].push vertex1

    distanceBetween: (vertex1, vertex2) ->

        @_distanceBetween[vertex1][vertex2] or Infinity

    vertices: -> vertex for vertex of @_neighbours

    # Follows the parent pointers returned by Dijkstra's algorithm to create
    # a path between source and target
    shortestPath: (previous, source, target) ->

        path = []
        while previous[target]
            path.unshift target
            target = previous[target]

        path

    dijkstras: (source, target) ->

        return unless source

        vertices = @vertices()

        # Initialize distance and previous
        # distance[v] is the distance from source vertex to v vertex
        # previous[v] is the previous node in the optimal path from source
        distance = {}
        previous = {}
        for vertex in vertices
            distance[vertex] = Infinity
            previous[vertex] = null

        distance[source] = 0

        while vertices.length
            
            closest = vertices[0]
            for neighbour in vertices.slice(1)
                closest = neighbour if distance[neighbour] < distance[closest]
            break if distance[closest] is Infinity

            # Remove closest from vertex set
            # TODO: Use a set data structure
            vertices.splice vertices.indexOf(closest), 1

            for neighbour in @_neighbours[closest]
                # TODO: Avoid this linear time operation by working with a copy 
                # of @neighbours
                continue if vertices.indexOf(neighbour) is -1

                # The length of the path from source to neighbour if it goes
                # through closest
                alt = distance[closest] + @distanceBetween closest, neighbour

                if alt < distance[neighbour]
                    distance[neighbour] = alt
                    previous[neighbour] = closest
                    
        return @shortestPath previous, source, target if target
        distance

    _weightlessGraph: ->

        for pair in @edgeWeights
            return false if pair.length isnt 2
        true

