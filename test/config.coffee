if require

    require.config

        baseUrl: '../'

        paths:
            'jquery': 'lib/jquery'

        map: '*':

else

    # Append any modules to the global namespace.
    window.define ?= (func) ->
        
        module = func()
        window[module.name] = module
