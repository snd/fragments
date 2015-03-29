example = require '../example/app'

fragments = require '../src/fragments'

module.exports =
  'getCommandNamesFromLifetime': (test) ->
    app = fragments()
    app (
      getCommandNamesFromLifetime
    ) ->
      lifetime =
        factories:
          command_app_myCommand: ->
          command_app_myOtherCommand: ->
          command_pg_migrate: ->
      test.deepEqual getCommandNamesFromLifetime(lifetime),
        [
          'app:my-command',
          'app:my-other-command'
          'pg:migrate'
        ]
      test.done()

  'unrecognized command': (test) ->
    app = fragments()
    app (
      runCommand
    ) ->
      try
        runCommand 'app:my-command'
      catch e
        test.equal e.message, 'no such command: app:my-command'
        test.done()

  'recognized command': (test) ->
    value1 = {}
    value2 = {}
    app = fragments
      application:
        command_app_myCommand: ->
          (arg1, arg2) ->
            test.equal arg1, value1
            test.equal arg2, value2
            test.done()
    app (
      runCommand
    ) ->
      runCommand 'app:my-command', value1, value2

  'getCommandHelpLinesFromLifetime': (test) ->
    app = fragments()
    app (
      getCommandHelpLinesFromLifetime
    ) ->
      lifetime =
        factories:
          command_bravo_charlie: ->
          command_alpha: ->
          command_alpha_bravo: ->
          command_bravo_alpha: ->
          command_alpha_bravo_charlie: ->
          command_bravo_bravo: ->
          command_bravo_charlie: ->
          command_delta_bravo_alpha: ->
          command_delta_bravo_echo: ->
          command_echo_delta: ->
      lifetime.factories.command_bravo_charlie.$help = 'does something'
      lifetime.factories.command_delta_bravo_alpha.$help = 'does something else'

      test.deepEqual getCommandHelpLinesFromLifetime(lifetime),
        [
          'alpha'
          'alpha:bravo'
          'alpha:bravo:charlie'
          'bravo:alpha'
          'bravo:bravo'
          'bravo:charlie does something'
          'delta:bravo:alpha does something else'
          'delta:bravo:echo'
          'echo:delta'
        ]

      test.deepEqual getCommandHelpLinesFromLifetime(lifetime, 'bravo'),
        [
          'bravo:alpha'
          'bravo:bravo'
          'bravo:charlie does something'
        ]

      test.deepEqual getCommandHelpLinesFromLifetime(lifetime, 'delta', 'bravo'),
        [
          'delta:bravo:alpha does something else'
          'delta:bravo:echo'
        ]

      test.deepEqual getCommandHelpLinesFromLifetime(lifetime, 'delta:bravo'),
        [
          'delta:bravo:alpha does something else'
          'delta:bravo:echo'
        ]

      test.deepEqual getCommandHelpLinesFromLifetime(lifetime, 'echo:delta'),
        [
          'echo:delta'
        ]
      test.done()

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
