define ->

    class Score

        constructor: (container) ->

            @_points = 0
            @_highscore = 0
            @_multiplier = 10
            @_setupDisplay container

        add: (amount = 1) ->

            @_set @_points + amount

        sub: (amount = 1, floor = false) ->

            if amount > @_points and floor
                @_set 0
                return

            @add -amount

        _set: (amount) ->

            return unless arguments.length > 0

            @_points = amount
            @_highscore = Math.max @_highscore, @_points

            html =  "high score<br />#{@_highscore * @_multiplier}<br />"
            html += "score<br />#{@_points * @_multiplier}"

            @_display.innerHTML = html

        _setupDisplay: (container) ->

            @_display = document.createElement 'DIV'
            @_display.id = 'score'
            @_set @_points
            container.appendChild @_display
