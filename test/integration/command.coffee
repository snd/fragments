example = require '../../example/app'

module.exports =

  'start and stop default server': (test) ->
    example (
      command_serve
      shutdown
    ) ->
      command_serve()
        .then ->
          shutdown()
        .then ->
          test.done()

  'start and stop custom server': (test) ->
    example (
      command_serve
      shutdown
    ) ->
      command_serve('helloWorldServer')
        .then ->
          shutdown()
        .then ->
          test.done()
