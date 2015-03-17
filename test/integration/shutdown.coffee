example = require '../../example/app'

module.exports =
  'repeated calls to runner use separate shutdown systems': (test) ->
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
