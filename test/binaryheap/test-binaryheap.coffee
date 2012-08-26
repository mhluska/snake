'import binaryheap'

class window.TestBinaryHeap extends Test

    before: ->

        @heap = new BinaryHeap (item) -> item
        @items = [4, 1, 2, 9, 8, 3, 5, 6, 7, 0]

        for item in @items
            @heap.push item

    testSize: -> 

        @assert @heap.size() is @items.length

    testBubbleUp: ->

        @show @heap._content.toString(), 'Heap array before bubble up:'

        temp = @heap._content[0]
        @heap._content[0] = @heap._content[@heap.size() - 1]
        @heap._content[@heap.size() - 1] = temp
        @heap.bubbleUp @heap.size() - 1

        @show @heap._content.toString(), 'Heap array after bubble up:'

        @assert @heap._content[0] is temp

    testBubbleDown: ->

        @show @heap._content.toString(), 'Heap array before sink down:'

        temp = @heap._content[@heap.size() - 1]
        @heap._content[@heap.size() - 1] = @heap._content[0]
        @heap._content[0] = temp
        @heap.sinkDown 0

        @show @heap._content.toString(), 'Heap array after sink down:'

        @assert @heap._content[@heap.size() - 1] is temp

    testPush: ->

        @assert @heap._content.length is 10

    testPop: ->

        for i in [0...@items.length]
            @assert @heap.pop() is i

    testRemove: ->

        @heap.remove 4
        @assert @equals @heap._content, [0, 1, 2, 6, 8, 3, 5, 9, 7]

        @heap.remove 5
        @assert @equals @heap._content, [0, 1, 2, 6, 8, 3, 7, 9]

