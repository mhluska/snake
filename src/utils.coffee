define ->

    class Utils

        @opposite: (direction) ->

            switch direction
                when 'up' then 'down'
                when 'right' then 'left'
                when 'down' then 'up'
                when 'left' then 'right'

        @extend: (object1, object2) ->

            for prop of object1
                object2[prop] ?= object1[prop]

        @flatten: (arr) ->

            [].concat.apply [], arr

        @difference: (arr1, arr2) ->

            obj = {}
            obj[elem] = true for elem in arr1
            delete obj[elem] for elem in arr2
            keys for keys of obj

        @getAxis: (unitVector) ->

            return 'x' if Math.abs(unitVector.x) is 1
            return 'y' if Math.abs(unitVector.y) is 1
            return 'z' if Math.abs(unitVector.z) is 1

        @randInt: (min, max) ->
            Math.floor(Math.random() * (max - min + 1)) + min
