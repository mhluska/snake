'import graph'

neighbours =
    a: ['b', 'c', 'd']
    b: ['a']
    c: ['a', 'd']
    d: ['a', 'c']
    e: []

edgeWeights = [
    ['a', 'b', 2]
    ['a', 'c', 8]
    ['a', 'd', 1]
    ['d', 'c', 9]
]

show neighbours, "Neighbours:"
assert neighbours['a'].length isnt 3, 'Vertex a has 3 neighbours'

show edgeWeights, "Edge weights:"

graph = new Game.Graph neighbours, edgeWeights

show graph.vertices(), 'Testing vertices:'

show graph._distanceBetween, 'Internal distanceBetween object:'

distance = graph.distanceBetween graph.vertices()[0], graph.vertices()[1]
show distance, 'Distance between vertices a and b:'

show graph.dijkstras(), "Result of Dijkstra's algorithm:"

