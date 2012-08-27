# Modified from http://eloquentjavascript.net/appendix2.html
# TODO: Publish BinaryHeap and HashMap in a data structures repo on GitHub. 

define ['src/hashmap'], (HashMap) ->

    class BinaryHeap

        constructor: (@scoreFunction = (item) -> item) ->

            @_content = []
            @_indexHash = new HashMap

        push: (element) ->

            @_content.push element
            @_indexHash.put element, @size() - 1
            @bubbleUp @size() - 1

        pop: ->

            result = @_content[0]
            end = @_content.pop()
            if @size() > 0
                @_content[0] = end
                @sinkDown(0)

            result

        remove: (node) ->

            # To remove a value, we must search through the array to find it.
            for item, index in @_content

                if item is node

                    # When it is found, the process seen in 'pop' is repeated
                    # to fill up the hole.
                    end = @_content.pop()
                    if index != @size() - 1
                        @_content[index] = end
                        if @scoreFunction(end) < @scoreFunction node
                            @bubbleUp index
                        else
                            @sinkDown index

                    return

            throw new Error 'Node not found'

        size: -> @_content.length

        last: -> @_content[@size() - 1]

        bubbleUp: (index) ->

            element = @_content[index]

            # When at 0, an element can not go up any further.
            while index > 0

                # Compute the parent element's index, and fetch it.
                parentN = Math.floor((index + 1) / 2) - 1
                parent = this._content[parentN]

                # Swap the elements if the parent is greater.
                if @scoreFunction(element) < @scoreFunction parent

                    @_content[parentN] = element
                    @_content[index] = parent
                    
                    @_indexHash.put element, parentN
                    @_indexHash.put parent, index

                    # Update 'index' to continue at the new position.
                    index = parentN

                # Found a parent that is less, no need to move it further.
                else break

        sinkDown: (index) ->

            # Look up the target element and its score.
            length = @size()
            element = @_content[index]
            elemScore = @scoreFunction element

            while true

                # Compute the indices of the child elements.
                child2N = (index + 1) * 2
                child1N = child2N - 1

                # This is used to store the new position of the element, if any.
                swap = null

                # If the first child exists (is inside the array)...
                if child1N < length

                    # Look it up and compute its score.
                    child1 = @_content[child1N]
                    child1Score = @scoreFunction child1

                    # If the score is less than our element's, we need to swap.
                    swap = child1N if child1Score < elemScore
                
                # Do the same checks for the other child.
                if child2N < length
                    child2 = @_content[child2N]
                    child2Score = @scoreFunction child2

                    score = if swap is null then elemScore else child1Score
                    if child2Score < score
                        swap = child2N

                # If the element needs to be moved, swap it, and continue.
                if swap isnt null

                    @_content[index] = @_content[swap]
                    @_content[swap] = element

                    @_indexHash.put @_content[swap], index
                    @_indexHash.put element, swap

                    index = swap

                else break

        indexOf: (element) ->

            index = @_indexHash.get(element)
            if index? then index else -1

        decreaseKey: (element) ->

            @bubbleUp @indexOf element
