define ->

    class Score

        constructor: (container) ->

            @_points = 0
            @_multiplier = 10
            @_setupDisplay container

        add: (amount = 1) ->

            @_points += amount
            @_set @_points

        sub: (amount = 1, floor = false) ->

            if amount > @_points and floor
                @_set 0
                return

            @add -amount

        _set: (amount) ->

            return unless arguments.length > 0
            @points = amount
            @_display.innerHTML = "Score<br />#{@_points * @_multiplier}"

        _setupDisplay: (container) ->

            @_display = document.createElement 'DIV'
            @_display.id = 'score'
            @_set @_points
            container.appendChild @_display
