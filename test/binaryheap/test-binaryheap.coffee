'import hashmap'
'import binaryheap'

class window.TestBinaryHeap extends Test

    before: ->

        @heap = new BinaryHeap
        @items = [4, 1, 2, 9, 8, 3, 5, 6, 7, 0]

        for item in @items
            @heap.push item

    swapEnds: ->

        temp = @heap._content[0]
        @heap._content[0] = @heap._content[@heap.size() - 1]
        @heap._content[@heap.size() - 1] = temp

    swapAndBubble: ->

        @show @heap._content.toString(), 'Heap array before bubble up:'
        @swapEnds()
        @heap.bubbleUp @heap.size() - 1
        @show @heap._content.toString(), 'Heap array after bubble up:'

    swapAndSink: ->

        @show @heap._content.toString(), 'Heap array before sink down:'
        @swapEnds()
        @heap.sinkDown 0
        @show @heap._content.toString(), 'Heap array after sink down:'

    testSize: ->

        @assert @heap.size() is @items.length

    testLast: ->

        @assert @heap.last() is 8

    testBubbleUp: ->

        @swapAndBubble()
        @assert @heap._content[0] is 0

    testBubbleDown: ->

        @swapAndSink()
        @assert @heap._content[@heap.size() - 1] is 8

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

    testIndexOf: ->

        @heap = new BinaryHeap
        @heap.push 24
        @assert @heap.indexOf(24) is @heap.size() - 1

        @before()

        @swapAndBubble()
        @assert @heap.indexOf(@heap._content[0]) is 0
        @assert @heap.indexOf(0) is 0

        @before()

        @swapAndSink()
        @assert @heap.indexOf(@heap._content[@heap.size() - 1]) is 9
        @assert @heap.indexOf(8) is 9

        @before
        @assert @heap.indexOf(Infinity) is -1

    testDecreaseKey: ->

        @swapAndSink()

        @heap.decreaseKey 8
        @show @heap._content.toString(), 'Heap array after decrease key:'
        @assert @heap.last() is 8

