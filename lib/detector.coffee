# TODO: Consider putting Detector into Game's dependencies to avoid this
# separate module. Downside is overhead of loading everything just to determine
# that WebGL is not supported. Is there a way around that?

class window.Detector

    constructor: ->

        @webgl = true
        @canvas = true

        canvas = document.createElement('canvas')
        @canvas = !!(canvas.getContext and canvas.getContext '2d')

        try
            throw new Error unless window.WebGLRenderingContext
            canvas = document.createElement('canvas')
            context = canvas.getContext('webgl') or canvas.getContext('experimental-webgl')
            context.getSupportedExtensions()

        catch error

            @webgl = false

    showWebGLError: (node) ->

        text = document.createElement 'p'
        text.innerHTML = [

            "It seems your browser doesn't support WebGL. "
            'Get it <a href="http://get.webgl.org/">here</a> or try the '
            '<a href="http://mhluska.com/demo/snake">2D snake demo</a>.'

        ].join('')

        text.className = 'notify'

        node.appendChild text
