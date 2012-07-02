# Allows the snake AI to find shortest paths between food items

window.Game ?= {}
class Game.Graph
    # Pass in adjacency lists like { a: ['b', 'c'], b: ['a'] }
    # where a, b, c are vertices and associations describe edges
    constructor: (@graph = {}) ->

    vertices: -> vertex for vertex of @graph

    dijkstras: (source) ->

        # Initialize distance and previous
        # distance[v] is the distance from source vertex to v vertex
        # previous[v] is the previous node in the optimal path from source
        distance = {}
        previous = {}
        for vertex of graph
            distance[vertex] = Infinity
            previous[vertex] = null

        distance[source] = 0

        vertices = @vertices()

        console.log vertices
        return

        while vertices.length
            
            closest = vertices[0]
            for neighbour in vertices.slice(1)
                closest = neighbour if distance[neighbour] < distance[closest]

            break if distance[closest] is Infinity

            vertices.splice vertices.indexOf(closest), 1

            for neighbour in @graph[closest]
                continue if vertices.indexOf neighbour is -1
