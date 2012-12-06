define [
    
    'hashmap'
    'binaryheap'

    ], (HashMap, BinaryHeap) ->

    class Graph

        # The snake game graph is very sparse: For thousands of vertices, each
        # vertex has a max of four neighbours. Also, our graph is modified on
        # the fly to save time in Dijkstra's algorithm. We store the graph in
        # an unconventional way for these reasons. We use an array of vertices
        # where each vertex maps to its 4-tuple of neighbours. This way we can
        # get neighbours in O(1) time while keeping things decoupled (not
        # relying on the neighbours info in the Square module).
        constructor: (@vertices = new HashMap) ->

        addVertex: (obj) ->

            return if @vertices.has obj

            # TODO: Don't do this. Make Square use HashMap for neighbours. Pass
            # it into the function so we don't rely on Square's internals.
            neighbours = (value for key, value of obj.neighbours)

            tuple = new HashMap
            for vertex in neighbours when @vertices.get(vertex)?
                tuple.put vertex
                @vertices.get(vertex).put obj

            @vertices.put obj, tuple

        removeVertex: (obj) ->

            return unless @vertices.has obj

            # TODO: Don't do this. Make Square use HashMap for neighbours. Pass
            # it into the function so we don't rely on Square's internals.
            neighbours = (value for key, value of obj.neighbours)

            for vertex in neighbours when @vertices.get(vertex)?
                @vertices.get(vertex).remove obj
                
            @vertices.remove obj

        # Note: we rely on source hashing nicely in distance[] because of its
        # toString function. Its a balance between module coupling and code
        # complexity.
        dijkstras: (source, targets...) ->

            previous = {}
            distance = {}

            heap = new BinaryHeap (item) -> distance[item]
            
            for vertex in @vertices.keys()
                distance[vertex] = Infinity
                distance[vertex] = 0 if vertex is source
                heap.push vertex

            while heap.size()

                closest = heap.pop()
                return [] if distance[closest] is Infinity

                break if closest in targets

                for neighbour in @vertices.get(closest).values()

                    continue if heap.indexOf(neighbour) is -1
                    
                    alt = distance[closest] + @_distance closest, neighbour

                    if alt < distance[neighbour]

                        distance[neighbour] = alt
                        previous[neighbour] = closest
                        heap.decreaseKey neighbour

            targets.sort (a, b) -> if distance[a] < distance[b] then -1 else 1

            @_shortestPath previous, source, targets[0]

        # Follows the parent pointers returned by Dijkstra's algorithm to
        # create a path between source and target
        _shortestPath: (previous, source, target) ->

            path = []
            while previous[target]
                path.unshift target
                target = previous[target]

            path

        _distance: (vertex1, vertex2) ->

            return Infinity unless @vertices.get(vertex1).has(vertex2)

            1

