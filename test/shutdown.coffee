fragments = require '../src/fragments'
example = require '../example/app'

module.exports =

  'zero shutdown callbacks': (test) ->
    app = fragments
      application:
        alpha: (onShutdown) ->
          null

    app (
      alpha
      shutdown
    ) ->
      shutdown().then ->
        test.done()

  'one sync shutdown callback': (test) ->
    test.expect 1

    app = fragments
      application:
        alpha: (onShutdown) ->
          onShutdown 'alpha', ->
            test.ok true

    app (
      alpha
      shutdown
    ) ->
      shutdown().then ->
        test.done()

  'one async shutdown callback': (test) ->
    test.expect 1

    app = fragments
      application:
        alpha: (onShutdown, Promise) ->
          onShutdown 'alpha', ->
            test.ok true
            Promise.delay(100)

    app (
      alpha
      shutdown
    ) ->
      shutdown().then ->
        test.done()

  'three async shutdown callbacks without order': (test) ->
    test.expect 3

    app = fragments
      application:
        alpha: (onShutdown, Promise) ->
          onShutdown 'alpha', ->
            test.ok true
            Promise.delay(100)
        bravo: (onShutdown, Promise) ->
          onShutdown 'bravo', ->
            test.ok true
            Promise.delay(100)
        charlie: (onShutdown, Promise) ->
          onShutdown 'charlie', ->
            test.ok true
            Promise.delay(100)

    app (
      alpha
      bravo
      charlie
      shutdown
    ) ->
      shutdown().then ->
        test.done()

  'three async shutdown callbacks with full order in series': (test) ->
    test.expect 9

    isShutDown =
      alpha: false
      bravo: false
      charlie: false

    app = fragments
      application:
        alpha: (onShutdown, shutdownBefore, Promise) ->
          # shutdown bravo before alpha
          shutdownBefore('bravo', 'alpha')
          onShutdown 'alpha', ->
            test.ok isShutDown.charlie
            test.ok isShutDown.bravo
            isShutDown.alpha = true
            Promise.delay(100)
        bravo: (onShutdown, shutdownBefore, Promise) ->
          # shutdown charlie before bravo
          shutdownBefore('charlie', 'bravo')
          onShutdown 'bravo', ->
            test.ok isShutDown.charlie
            test.ok not isShutDown.alpha
            isShutDown.bravo = true
            Promise.delay(100)
        charlie: (onShutdown, Promise) ->
          onShutdown 'charlie', ->
            test.ok not isShutDown.alpha
            test.ok not isShutDown.bravo
            isShutDown.charlie = true
            Promise.delay(100)

    app (
      alpha
      bravo
      charlie
      shutdown
    ) ->
      shutdown().then ->
        test.ok isShutDown.alpha
        test.ok isShutDown.bravo
        test.ok isShutDown.charlie
        test.done()

  'three async shutdown callbacks with partial order': (test) ->
    test.expect 6

    isShutDown =
      alpha: false
      bravo: false
      charlie: false

    app = fragments
      application:
        alpha: (onShutdown, shutdownBefore, Promise) ->
          # shutdown bravo before alpha
          shutdownBefore('bravo', 'alpha')
          onShutdown 'alpha', ->
            test.ok isShutDown.bravo
            isShutDown.alpha = true
            Promise.delay(100)
        bravo: (onShutdown, shutdownBefore, Promise) ->
          onShutdown 'bravo', ->
            test.ok not isShutDown.alpha
            isShutDown.bravo = true
            Promise.delay(100)
        charlie: (onShutdown, Promise) ->
          onShutdown 'charlie', ->
            test.ok true
            isShutDown.charlie = true
            Promise.delay(100)

    app (
      alpha
      bravo
      charlie
      shutdown
    ) ->
      shutdown().then ->
        test.ok isShutDown.alpha
        test.ok isShutDown.bravo
        test.ok isShutDown.charlie
        test.done()

  'three shutdown callbacks with full order with parallel parts': (test) ->
    test.expect 7

    isShutDown =
      alpha: false
      bravo: false
      charlie: false

    app = fragments
      application:
        alpha: (onShutdown, shutdownBefore, Promise) ->
          # shutdown charlie before alpha
          shutdownBefore('charlie', 'alpha')
          # shutdown bravo before alpha
          shutdownBefore('bravo', 'alpha')
          onShutdown 'alpha', ->
            test.ok isShutDown.charlie
            test.ok isShutDown.bravo
            isShutDown.alpha = true
            Promise.delay(100)
        bravo: (onShutdown, shutdownBefore, Promise) ->
          onShutdown 'bravo', ->
            test.ok not isShutDown.alpha
            isShutDown.bravo = true
            Promise.delay(100)
        charlie: (onShutdown, Promise) ->
          onShutdown 'charlie', ->
            test.ok not isShutDown.alpha
            isShutDown.charlie = true
            Promise.delay(100)

    app (
      alpha
      bravo
      charlie
      shutdown
    ) ->
      shutdown().then ->
        test.ok isShutDown.alpha
        test.ok isShutDown.bravo
        test.ok isShutDown.charlie
        test.done()

  'ids in orders that have no callbacks are ignored': (test) ->
    test.expect 7

    isShutDown =
      alpha: false
      bravo: false
      charlie: false

    app = fragments
      application:
        alpha: (onShutdown, shutdownBefore, Promise) ->
          shutdownBefore('charlie', 'alpha')
          shutdownBefore('bravo', 'alpha')
          # delta does not exist
          shutdownBefore('delta', 'alpha')
          shutdownBefore('echo', 'alpha')
          onShutdown 'alpha', ->
            test.ok isShutDown.charlie
            test.ok isShutDown.bravo
            isShutDown.alpha = true
            Promise.delay(100)
        bravo: (onShutdown, shutdownBefore, Promise) ->
          shutdownBefore('delta', 'bravo')
          onShutdown 'bravo', ->
            test.ok not isShutDown.alpha
            isShutDown.bravo = true
            Promise.delay(100)
        charlie: (onShutdown, shutdownBefore, Promise) ->
          shutdownBefore('echo', 'charlie')
          onShutdown 'charlie', ->
            test.ok not isShutDown.alpha
            isShutDown.charlie = true
            Promise.delay(100)

    app (
      alpha
      bravo
      charlie
      shutdown
    ) ->
      shutdown().then ->
        test.ok isShutDown.alpha
        test.ok isShutDown.bravo
        test.ok isShutDown.charlie
        test.done()

  'repeated calls to app use separate shutdown systems': (test) ->
    example (
      command_serve
      shutdown
      shutdownState
    ) ->
      shutdownState1 = shutdownState
      test.ok not shutdownState1.isShutdown
      command_serve()
        .then ->
          test.ok not shutdownState1.isShutdown
          shutdown()
        .then ->
          test.ok shutdownState1.isShutdown
          example (
            command_serve
            shutdown
            shutdownState
          ) ->
            shutdownState2 = shutdownState
            test.ok not shutdownState2.isShutdown
            command_serve()
              .then ->
                test.ok not shutdownState2.isShutdown
                shutdown()
              .then ->
                test.ok shutdownState1.isShutdown
                test.done()

  'shutdown can only be called once per application lifetime': (test) ->
    example (
      command_serve
      shutdown
    ) ->
      command_serve()
        .then ->
          shutdown()
        .then ->
          try
            shutdown()
          catch e
            test.equal e.message, 'shutdown can only be called once per application lifetime'
          test.done()
