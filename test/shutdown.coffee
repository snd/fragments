test = require 'tape'

fragments = require '../lib/fragments'
example = require '../example/app'

test 'zero shutdown callbacks', (t) ->
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
      t.end()

test 'one sync shutdown callback', (t) ->
  t.plan 1

  app = fragments([
    fragments.source
    {
      alpha: (fragments_onShutdown) ->
        fragments_onShutdown 'alpha', ->
          t.ok true
    }
  ])

  app (
    alpha
    fragments_shutdown
  ) ->
    fragments_shutdown().then ->
      t.end()

test 'one async shutdown callback', (t) ->
  t.plan 1

  app = fragments([
    fragments.source
    {
      alpha: (fragments_onShutdown, fragments_Promise) ->
        fragments_onShutdown 'alpha', ->
          t.ok true
          fragments_Promise.delay(100)
    }
  ])

  app (
    alpha
    fragments_shutdown
  ) ->
    fragments_shutdown().then ->
      t.end()

test 'three async shutdown callbacks without order', (t) ->
  t.plan 3

  app = fragments([
    fragments.source
    {
      alpha: (fragments_onShutdown, fragments_Promise) ->
        fragments_onShutdown 'alpha', ->
          t.ok true
          fragments_Promise.delay(100)
      bravo: (fragments_onShutdown, fragments_Promise) ->
        fragments_onShutdown 'bravo', ->
          t.ok true
          fragments_Promise.delay(100)
      charlie: (fragments_onShutdown, fragments_Promise) ->
        fragments_onShutdown 'charlie', ->
          t.ok true
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
      t.end()

test 'three async shutdown callbacks with full order in series', (t) ->
  t.plan 9

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
          t.ok isShutDown.charlie
          t.ok isShutDown.bravo
          isShutDown.alpha = true
          fragments_Promise.delay(100)
      bravo: (fragments_onShutdown, fragments_shutdownBefore, fragments_Promise) ->
        # shutdown charlie before bravo
        fragments_shutdownBefore('charlie', 'bravo')
        fragments_onShutdown 'bravo', ->
          t.ok isShutDown.charlie
          t.ok not isShutDown.alpha
          isShutDown.bravo = true
          fragments_Promise.delay(100)
      charlie: (fragments_onShutdown, fragments_Promise) ->
        fragments_onShutdown 'charlie', ->
          t.ok not isShutDown.alpha
          t.ok not isShutDown.bravo
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
      t.ok isShutDown.alpha
      t.ok isShutDown.bravo
      t.ok isShutDown.charlie
      t.end()

test 'three async shutdown callbacks with partial order', (t) ->
  t.plan 6

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
          t.ok isShutDown.bravo
          isShutDown.alpha = true
          fragments_Promise.delay(100)
      bravo: (fragments_onShutdown, fragments_shutdownBefore, fragments_Promise) ->
        fragments_onShutdown 'bravo', ->
          t.ok not isShutDown.alpha
          isShutDown.bravo = true
          fragments_Promise.delay(100)
      charlie: (fragments_onShutdown, fragments_Promise) ->
        fragments_onShutdown 'charlie', ->
          t.ok true
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
      t.ok isShutDown.alpha
      t.ok isShutDown.bravo
      t.ok isShutDown.charlie
      t.end()

test 'three shutdown callbacks with full order with parallel parts', (t) ->
  t.plan 7

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
          t.ok isShutDown.charlie
          t.ok isShutDown.bravo
          isShutDown.alpha = true
          fragments_Promise.delay(100)
      bravo: (fragments_onShutdown, fragments_shutdownBefore, fragments_Promise) ->
        fragments_onShutdown 'bravo', ->
          t.ok not isShutDown.alpha
          isShutDown.bravo = true
          fragments_Promise.delay(100)
      charlie: (fragments_onShutdown, fragments_Promise) ->
        fragments_onShutdown 'charlie', ->
          t.ok not isShutDown.alpha
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
      t.ok isShutDown.alpha
      t.ok isShutDown.bravo
      t.ok isShutDown.charlie
      t.end()

test 'ids in orders that have no callbacks are ignored', (t) ->
  t.plan 7

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
          t.ok isShutDown.charlie
          t.ok isShutDown.bravo
          isShutDown.alpha = true
          fragments_Promise.delay(100)
      bravo: (fragments_onShutdown, fragments_shutdownBefore, fragments_Promise) ->
        fragments_shutdownBefore('delta', 'bravo')
        fragments_onShutdown 'bravo', ->
          t.ok not isShutDown.alpha
          isShutDown.bravo = true
          fragments_Promise.delay(100)
      charlie: (fragments_onShutdown, fragments_shutdownBefore, fragments_Promise) ->
        fragments_shutdownBefore('echo', 'charlie')
        fragments_onShutdown 'charlie', ->
          t.ok not isShutDown.alpha
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
      t.ok isShutDown.alpha
      t.ok isShutDown.bravo
      t.ok isShutDown.charlie
      t.end()

test 'repeated calls to app use separate shutdown systems', (t) ->
  example (
    command_serve
    shutdown
    shutdownState
    fragments_applicationLifetime
  ) ->
    shutdownState1 = shutdownState
    t.ok not shutdownState1.isShutdown
    command_serve()
      .then ->
        console.log 'serve', shutdownState1
        # console.log 'applicationLifetime', fragments_applicationLifetime
        t.ok not shutdownState1.isShutdown
        shutdown()
      .then ->
        console.log 'after shutdown', shutdownState1
        t.ok shutdownState1.isShutdown
        example (
          command_serve
          shutdown
          shutdownState
        ) ->
          shutdownState2 = shutdownState
          t.ok not shutdownState2.isShutdown
          command_serve()
            .then ->
              t.ok not shutdownState2.isShutdown
              shutdown()
            .then ->
              # t.ok shutdownState2.isShutdown
              t.end()

test 'shutdown can only be called once per application lifetime', (t) ->
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
          t.equal e.message, 'shutdown can only be called once per application lifetime'
        t.end()
