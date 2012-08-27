if window.require

    require.config

        baseUrl: '../'

        paths:
            'jquery': 'lib/jquery'

        map: '*': {}

else

    # Append any modules to the global namespace for testing.
    window.define ?= (deps, func) ->

        # Handle single or double parameter forms of define.
        func = deps if typeof(deps) is 'function'

        # Pass any dependencies to the module from the global namespace.
        funStr = func.toString()
        params = funStr.slice(funStr.indexOf('(')+1, funStr.indexOf(')'))
            .match(/([^\s,]+)/g) or []
        windowParams = (window[param] for param in params)
        
        module = func windowParams...

        # Set this module in the global namespace.
        window[module.name] = module
