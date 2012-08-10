define ->

    class Utils

        @opposite: (thing) ->

            switch thing
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

