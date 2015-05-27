fragments = require '../src/fragments'
example = require '../example/app'

module.exports =

  'zero shutdown callbacks': (test) ->
    app = fragments([
      fragments.source
      {
        alpha: (fragments_onShutdown) ->
          null
      }
    ])

    app (
      alpha
      fragments_shutdown
    ) ->
      fragments_shutdown().then ->
        test.done()

  'one sync shutdown callback': (test) ->
    test.expect 1

    app = fragments([
      fragments.source
      {
        alpha: (fragments_onShutdown) ->
          fragments_onShutdown 'alpha', ->
            test.ok true
      }
    ])

    app (
      alpha
      fragments_shutdown
    ) ->
      fragments_shutdown().then ->
        test.done()

  'one async shutdown callback': (test) ->
    test.expect 1

    app = fragments([
      fragments.source
      {
        alpha: (fragments_onShutdown, fragments_Promise) ->
          fragments_onShutdown 'alpha', ->
            test.ok true
            fragments_Promise.delay(100)
      }
    ])

    app (
      alpha
      fragments_shutdown
    ) ->
      fragments_shutdown().then ->
        test.done()

  'three async shutdown callbacks without order': (test) ->
    test.expect 3

    app = fragments([
      fragments.source
      {
        alpha: (fragments_onShutdown, fragments_Promise) ->
          fragments_onShutdown 'alpha', ->
            test.ok true
            fragments_Promise.delay(100)
        bravo: (fragments_onShutdown, fragments_Promise) ->
          fragments_onShutdown 'bravo', ->
            test.ok true
            fragments_Promise.delay(100)
        charlie: (fragments_onShutdown, fragments_Promise) ->
          fragments_onShutdown 'charlie', ->
            test.ok true
            fragments_Promise.delay(100)
      }
    ])

    app (
      alpha
      bravo
      charlie
      fragments_shutdown
    ) ->
      fragments_shutdown().then ->
        test.done()

  'three async shutdown callbacks with full order in series': (test) ->
    test.expect 9

    isShutDown =
      alpha: false
      bravo: false
      charlie: false

    app = fragments([
      fragments.source
      {
        alpha: (fragments_onShutdown, fragments_shutdownBefore, fragments_Promise) ->
          # shutdown bravo before alpha
          fragments_shutdownBefore('bravo', 'alpha')
          fragments_onShutdown 'alpha', ->
            test.ok isShutDown.charlie
            test.ok isShutDown.bravo
            isShutDown.alpha = true
            fragments_Promise.delay(100)
        bravo: (fragments_onShutdown, fragments_shutdownBefore, fragments_Promise) ->
          # shutdown charlie before bravo
          fragments_shutdownBefore('charlie', 'bravo')
          fragments_onShutdown 'bravo', ->
            test.ok isShutDown.charlie
            test.ok not isShutDown.alpha
            isShutDown.bravo = true
            fragments_Promise.delay(100)
        charlie: (fragments_onShutdown, fragments_Promise) ->
          fragments_onShutdown 'charlie', ->
            test.ok not isShutDown.alpha
            test.ok not isShutDown.bravo
            isShutDown.charlie = true
            fragments_Promise.delay(100)
      }
    ])

    app (
      alpha
      bravo
      charlie
      fragments_shutdown
    ) ->
      fragments_shutdown().then ->
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

    app = fragments([
      fragments.source
      {
        alpha: (fragments_onShutdown, fragments_shutdownBefore, fragments_Promise) ->
          # shutdown bravo before alpha
          fragments_shutdownBefore('bravo', 'alpha')
          fragments_onShutdown 'alpha', ->
            test.ok isShutDown.bravo
            isShutDown.alpha = true
            fragments_Promise.delay(100)
        bravo: (fragments_onShutdown, fragments_shutdownBefore, fragments_Promise) ->
          fragments_onShutdown 'bravo', ->
            test.ok not isShutDown.alpha
            isShutDown.bravo = true
            fragments_Promise.delay(100)
        charlie: (fragments_onShutdown, fragments_Promise) ->
          fragments_onShutdown 'charlie', ->
            test.ok true
            isShutDown.charlie = true
            fragments_Promise.delay(100)
      }
    ])

    app (
      alpha
      bravo
      charlie
      fragments_shutdown
    ) ->
      fragments_shutdown().then ->
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

    app = fragments([
      fragments.source
      {
        alpha: (fragments_onShutdown, fragments_shutdownBefore, fragments_Promise) ->
          # shutdown charlie before alpha
          fragments_shutdownBefore('charlie', 'alpha')
          # shutdown bravo before alpha
          fragments_shutdownBefore('bravo', 'alpha')
          fragments_onShutdown 'alpha', ->
            test.ok isShutDown.charlie
            test.ok isShutDown.bravo
            isShutDown.alpha = true
            fragments_Promise.delay(100)
        bravo: (fragments_onShutdown, fragments_shutdownBefore, fragments_Promise) ->
          fragments_onShutdown 'bravo', ->
            test.ok not isShutDown.alpha
            isShutDown.bravo = true
            fragments_Promise.delay(100)
        charlie: (fragments_onShutdown, fragments_Promise) ->
          fragments_onShutdown 'charlie', ->
            test.ok not isShutDown.alpha
            isShutDown.charlie = true
            fragments_Promise.delay(100)
      }
    ])

    app (
      alpha
      bravo
      charlie
      fragments_shutdown
    ) ->
      fragments_shutdown().then ->
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

    app = fragments([
      fragments.source
      {
        alpha: (fragments_onShutdown, fragments_shutdownBefore, fragments_Promise) ->
          fragments_shutdownBefore('charlie', 'alpha')
          fragments_shutdownBefore('bravo', 'alpha')
          # delta does not exist
          fragments_shutdownBefore('delta', 'alpha')
          fragments_shutdownBefore('echo', 'alpha')
          fragments_onShutdown 'alpha', ->
            test.ok isShutDown.charlie
            test.ok isShutDown.bravo
            isShutDown.alpha = true
            fragments_Promise.delay(100)
        bravo: (fragments_onShutdown, fragments_shutdownBefore, fragments_Promise) ->
          fragments_shutdownBefore('delta', 'bravo')
          fragments_onShutdown 'bravo', ->
            test.ok not isShutDown.alpha
            isShutDown.bravo = true
            fragments_Promise.delay(100)
        charlie: (fragments_onShutdown, fragments_shutdownBefore, fragments_Promise) ->
          fragments_shutdownBefore('echo', 'charlie')
          fragments_onShutdown 'charlie', ->
            test.ok not isShutDown.alpha
            isShutDown.charlie = true
            fragments_Promise.delay(100)
      }
    ])

    app (
      alpha
      bravo
      charlie
      fragments_shutdown
    ) ->
      fragments_shutdown().then ->
        test.ok isShutDown.alpha
        test.ok isShutDown.bravo
        test.ok isShutDown.charlie
        test.done()

  'repeated calls to app use separate shutdown systems': (test) ->
    example (
      command_serve
      shutdown
      shutdownState
      fragments_applicationLifetime
    ) ->
      shutdownState1 = shutdownState
      test.ok not shutdownState1.isShutdown
      command_serve()
        .then ->
          console.log 'serve', shutdownState1
          # console.log 'applicationLifetime', fragments_applicationLifetime
          test.ok not shutdownState1.isShutdown
          shutdown()
        .then ->
          console.log 'after shutdown', shutdownState1
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
                # test.ok shutdownState2.isShutdown
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
