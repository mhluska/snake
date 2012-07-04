# Allows the snake AI to find shortest paths between food items

window.Game ?= {}
class Game.Graph
    # The constructor takes two parameters which describe the graph:
    #
    # An object where a key describes vertex u and associations describe 
    # neighbours of u
    # { a: ['b', 'c', 'd'], b: ['a'], c: ['a', 'd'], d: ['a', 'c'], e: []}
    #
    # Edge weights encoded as 3-arrays. Since we are working with undirected 
    # graphs, the ordering of the first two values does not matter. The third 
    # value must be the edge weight.
    # [ ['a', 'b', 2], ['a', 'c', 8], ['a', 'd', 1], ['d', 'c', 9] ]
    constructor: (@neighbours = {}, @edgeWeights = []) ->

        # Setup bi-directional distances between vertices
        @_distanceBetween = {}
        for triple in @edgeWeights
            [vertex1, vertex2, weight] = triple
            @_distanceBetween[vertex1] ?= {}
            @_distanceBetween[vertex2] ?= {}
            @_distanceBetween[vertex1][vertex2] = weight
            @_distanceBetween[vertex2][vertex1] = weight

    distanceBetween: (vertex1, vertex2) ->

        ret = @_distanceBetween[vertex1][vertex2] or Infinity
        console.log "distanceBetween returning #{ret}"
        ret

    vertices: -> vertex for vertex of @neighbours

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

            for neighbour in @neighbours[closest]
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
        previous
