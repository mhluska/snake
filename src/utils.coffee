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
