hinoki = require 'hinoki'
Promise = require 'bluebird'

applicationFactories = require('../../src/fragments').application

newLifetime = ->
  factories: Object.create applicationFactories

module.exports =

  'zero shutdown callbacks': (test) ->
    lifetime = newLifetime()

    lifetime.factories.alpha = (fragments_onShutdown) ->
      null

    # force dependencies to be created to register their shutdown callbacks
    hinoki.get(lifetime, 'alpha')
      .then ->
        hinoki.get(lifetime, 'fragments_shutdown')
      .then (shutdown) ->
        shutdown()
      .then ->
        test.done()

  'one sync shutdown callback': (test) ->
    test.expect 1

    lifetime = newLifetime()

    lifetime.factories.alpha = (fragments_onShutdown) ->
      fragments_onShutdown 'alpha', ->
        test.ok true

    # force dependencies to be created to register their shutdown callbacks
    hinoki.get(lifetime, 'alpha')
      .then ->
        hinoki.get(lifetime, 'fragments_shutdown')
      .then (shutdown) ->
        shutdown()
      .then ->
        test.done()

  'one async shutdown callback': (test) ->
    test.expect 1

    lifetime = newLifetime()

    lifetime.factories.alpha = (fragments_onShutdown) ->
      fragments_onShutdown 'alpha', ->
        test.ok true
        Promise.delay(100)

    # force dependencies to be created to register their shutdown callbacks
    hinoki.get(lifetime, 'alpha')
      .then ->
        hinoki.get(lifetime, 'fragments_shutdown')
      .then (shutdown) ->
        shutdown()
      .then ->
        test.done()

  'three async shutdown callbacks without order': (test) ->
    test.expect 3

    lifetime = newLifetime()

    lifetime.factories.alpha = (fragments_onShutdown) ->
      fragments_onShutdown 'alpha', ->
        test.ok true
        Promise.delay(100)
    lifetime.factories.bravo = (fragments_onShutdown) ->
      fragments_onShutdown 'bravo', ->
        test.ok true
        Promise.delay(100)
    lifetime.factories.charlie = (fragments_onShutdown) ->
      fragments_onShutdown 'charlie', ->
        test.ok true
        Promise.delay(100)

    # force dependencies to be created to register their shutdown callbacks
    hinoki.get(lifetime, ['alpha', 'bravo', 'charlie'])
      .then ->
        hinoki.get(lifetime, 'fragments_shutdown')
      .then (shutdown) ->
        shutdown()
      .then ->
        test.done()

  'three async shutdown callbacks with full order in series': (test) ->
    test.expect 9

    lifetime = newLifetime()

    isShutDown =
      alpha: false
      bravo: false
      charlie: false

    lifetime.factories.alpha = (fragments_onShutdown, fragments_shutdownBefore) ->
      # shutdown bravo before alpha
      fragments_shutdownBefore('bravo', 'alpha')
      fragments_onShutdown 'alpha', ->
        test.ok isShutDown.charlie
        test.ok isShutDown.bravo
        isShutDown.alpha = true
        Promise.delay(100)
    lifetime.factories.bravo = (fragments_onShutdown, fragments_shutdownBefore) ->
      # shutdown charlie before bravo
      fragments_shutdownBefore('charlie', 'bravo')
      fragments_onShutdown 'bravo', ->
        test.ok isShutDown.charlie
        test.ok not isShutDown.alpha
        isShutDown.bravo = true
        Promise.delay(100)
    lifetime.factories.charlie = (fragments_onShutdown) ->
      fragments_onShutdown 'charlie', ->
        test.ok not isShutDown.alpha
        test.ok not isShutDown.bravo
        isShutDown.charlie = true
        Promise.delay(100)

    # force dependencies to be created to register their shutdown callbacks
    hinoki.get(lifetime, ['alpha', 'bravo', 'charlie'])
      .then ->
        hinoki.get(lifetime, 'fragments_shutdown')
      .then (shutdown) ->
        shutdown()
      .then ->
        test.ok isShutDown.alpha
        test.ok isShutDown.bravo
        test.ok isShutDown.charlie
        test.done()

  'three async shutdown callbacks with partial order': (test) ->
    test.expect 6

    lifetime = newLifetime()

    isShutDown =
      alpha: false
      bravo: false
      charlie: false

    lifetime.factories.alpha = (fragments_onShutdown, fragments_shutdownBefore) ->
      # shutdown bravo before alpha
      fragments_shutdownBefore('bravo', 'alpha')
      fragments_onShutdown 'alpha', ->
        test.ok isShutDown.bravo
        isShutDown.alpha = true
        Promise.delay(100)
    lifetime.factories.bravo = (fragments_onShutdown, fragments_shutdownBefore) ->
      fragments_onShutdown 'bravo', ->
        test.ok not isShutDown.alpha
        isShutDown.bravo = true
        Promise.delay(100)
    lifetime.factories.charlie = (fragments_onShutdown) ->
      fragments_onShutdown 'charlie', ->
        test.ok true
        isShutDown.charlie = true
        Promise.delay(100)

    # force dependencies to be created to register their shutdown callbacks
    hinoki.get(lifetime, ['alpha', 'bravo', 'charlie'])
      .then ->
        hinoki.get(lifetime, 'fragments_shutdown')
      .then (shutdown) ->
        shutdown()
      .then ->
        test.ok isShutDown.alpha
        test.ok isShutDown.bravo
        test.ok isShutDown.charlie
        test.done()

  'three shutdown callbacks with full order with parallel parts': (test) ->
    test.expect 7

    lifetime = newLifetime()

    isShutDown =
      alpha: false
      bravo: false
      charlie: false

    lifetime.factories.alpha = (fragments_onShutdown, fragments_shutdownBefore) ->
      # shutdown charlie before alpha
      fragments_shutdownBefore('charlie', 'alpha')
      # shutdown bravo before alpha
      fragments_shutdownBefore('bravo', 'alpha')
      fragments_onShutdown 'alpha', ->
        test.ok isShutDown.charlie
        test.ok isShutDown.bravo
        isShutDown.alpha = true
        Promise.delay(100)
    lifetime.factories.bravo = (fragments_onShutdown, fragments_shutdownBefore) ->
      fragments_onShutdown 'bravo', ->
        test.ok not isShutDown.alpha
        isShutDown.bravo = true
        Promise.delay(100)
    lifetime.factories.charlie = (fragments_onShutdown) ->
      fragments_onShutdown 'charlie', ->
        test.ok not isShutDown.alpha
        isShutDown.charlie = true
        Promise.delay(100)

    # force dependencies to be created to register their shutdown callbacks
    hinoki.get(lifetime, ['alpha', 'bravo', 'charlie'])
      .then ->
        hinoki.get(lifetime, 'fragments_shutdown')
      .then (shutdown) ->
        shutdown()
      .then ->
        test.ok isShutDown.alpha
        test.ok isShutDown.bravo
        test.ok isShutDown.charlie
        test.done()

  'ids in orders that have no callbacks are ignored': (test) ->
    test.expect 7

    lifetime = newLifetime()

    isShutDown =
      alpha: false
      bravo: false
      charlie: false

    lifetime.factories.alpha = (fragments_onShutdown, fragments_shutdownBefore) ->
      fragments_shutdownBefore('charlie', 'alpha')
      fragments_shutdownBefore('bravo', 'alpha')
      # delta does not exist
      fragments_shutdownBefore('delta', 'alpha')
      fragments_shutdownBefore('echo', 'alpha')
      fragments_onShutdown 'alpha', ->
        test.ok isShutDown.charlie
        test.ok isShutDown.bravo
        isShutDown.alpha = true
        Promise.delay(100)
    lifetime.factories.bravo = (fragments_onShutdown, fragments_shutdownBefore) ->
      fragments_shutdownBefore('delta', 'bravo')
      fragments_onShutdown 'bravo', ->
        test.ok not isShutDown.alpha
        isShutDown.bravo = true
        Promise.delay(100)
    lifetime.factories.charlie = (fragments_onShutdown, fragments_shutdownBefore) ->
      fragments_shutdownBefore('echo', 'charlie')
      fragments_onShutdown 'charlie', ->
        test.ok not isShutDown.alpha
        isShutDown.charlie = true
        Promise.delay(100)

    # force dependencies to be created to register their shutdown callbacks
    hinoki.get(lifetime, ['alpha', 'bravo', 'charlie'])
      .then ->
        hinoki.get(lifetime, 'fragments_shutdown')
      .then (shutdown) ->
        shutdown()
      .then ->
        test.ok isShutDown.alpha
        test.ok isShutDown.bravo
        test.ok isShutDown.charlie
        test.done()
