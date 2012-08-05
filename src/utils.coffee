define ->

    class Utils

        @opposite: (thing) ->

            switch thing
                when 'up' then 'down'
                when 'right' then 'left'
                when 'down' then 'up'
                when 'left' then 'right'
