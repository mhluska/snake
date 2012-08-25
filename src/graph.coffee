define [
    
    'src/hashmap'
    'src/queue'
    'src/utils'

    ], (HashMap, Queue, Utils) ->

    class Graph

        constructor: (@neighbours = {}) ->

        removeVertex: (square) ->

            return unless @neighbours[square]

            for pos, neighbour of square.neighbours when @neighbours[neighbour]

                index = @neighbours[neighbour].indexOf square.toString()
                @neighbours[neighbour].splice index, 1

            delete @neighbours[square]

        addVertex: (square) ->

            return if @neighbours[square]

            @neighbours[square] = []

            for pos, neighbour of square.neighbours

                @neighbours[square].push neighbour.toString()
                @neighbours[neighbour]?.push square.toString()

        vertices: -> vertex for vertex of @neighbours

        distanceBetween: (vertex1, vertex2) ->

            return Infinity if vertex2.toString() not in @neighbours[vertex1]
            
            1

        # dijkstras(source, [targets, ...])
        # Accepts a source and any number of target vertices. If target 
        # vertices are provided, returns a shortest path from each source to 
        # target path. If no targets are provided, returns distances from 
        # source to every other vertex.
        dijkstras: (source, targets...) ->

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
                    # TODO: Avoid this linear time operation by working with a 
                    # copy of @neighbours
                    continue if neighbour not in vertices

                    # The length of the path from source to neighbour if it 
                    # goes through closest
                    alt = distance[closest] + @distanceBetween closest, neighbour

                    if alt < distance[neighbour]
                        distance[neighbour] = alt
                        previous[neighbour] = closest
                        
            return distance unless targets.length

            pathDistances = (distance[target] for target in targets)
            minDistance = Math.min.apply null, pathDistances
            targetIndex = pathDistances.indexOf minDistance

            @_shortestPath previous, source, targets[targetIndex]

        # Follows the parent pointers returned by Dijkstra's algorithm to 
        # create a path between source and target
        _shortestPath: (previous, source, target) ->

            path = new Queue
            while previous[target]
                path.enqueue target
                target = previous[target]

            path
