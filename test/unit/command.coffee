fragments = require '../../src/fragments'

module.exports =

  'unrecognized command': (test) ->
    lifetime =
      factories: {}

    try
      fragments.runCommand lifetime, 'app:my-command'
    catch e
      test.equal e.message, 'unrecognized command: app:my-command'
      test.done()

  'recognized command': (test) ->
    value1 = {}
    value2 = {}
    lifetime =
      factories:
        command_app_myCommand: ->
          (arg1, arg2) ->
            test.equal arg1, value1
            test.equal arg2, value2
            test.done()
    fragments.runCommand lifetime, 'app:my-command', value1, value2

  'getCommandNamesFromLifetime': (test) ->
    lifetime =
      factories:
        command_app_myCommand: ->
        command_app_myOtherCommand: ->
        command_pg_migrate: ->
    test.deepEqual fragments.getCommandNamesFromLifetime(lifetime),
      ['app:my-command', 'app:my-other-command', 'pg:migrate']
    test.done()
