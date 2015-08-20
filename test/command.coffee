test = require 'tape'
hinoki = require 'hinoki'

fragments = require '../lib/fragments'
example = require '../example/app'

  # test 'getCommandNamesFromLifetime', (t) ->
  #   fragments (
  #     fragments_getCommandNamesFromLifetime
  #   ) ->
  #     lifetime =
  #       factories:
  #         command_app_myCommand: ->
  #         command_app_myOtherCommand: ->
  #         command_pg_migrate: ->
  #     t.deepEqual fragments_getCommandNamesFromLifetime(lifetime),
  #       [
  #         'app:my-command',
  #         'app:my-other-command'
  #         'pg:migrate'
  #       ]
  #     t.end()

test 'unrecognized command', (t) ->
  app = fragments()
  app (
    fragments_runCommand
  ) ->
    try
      fragments_runCommand 'app:my-command'
    catch e
      t.equal e.message, 'no such command: app:my-command'
      t.end()

test 'recognized command', (t) ->
  app = fragments [
    fragments.source
    {
      command_app_myCommand: ->
        (arg1, arg2) ->
          t.equal arg1, value1
          t.equal arg2, value2
          t.end()
    }
  ]
  value1 = {}
  value2 = {}
  app (
    fragments_runCommand
  ) ->
    fragments_runCommand 'app:my-command', value1, value2

#   test 'getCommandHelpLinesFromLifetime', (t) ->
#     app = fragments()
#     app (
#       getCommandHelpLinesFromLifetime
#     ) ->
#       lifetime =
#         factories:
#           command_bravo_charlie: ->
#           command_alpha: ->
#           command_alpha_bravo: ->
#           command_bravo_alpha: ->
#           command_alpha_bravo_charlie: ->
#           command_bravo_bravo: ->
#           command_bravo_charlie: ->
#           command_delta_bravo_alpha: ->
#           command_delta_bravo_echo: ->
#           command_echo_delta: ->
#       lifetime.factories.command_bravo_charlie.$help = 'does something'
#       lifetime.factories.command_delta_bravo_alpha.$help = 'does something else'
#
#       t.deepEqual getCommandHelpLinesFromLifetime(lifetime),
#         [
#           'alpha'
#           'alpha:bravo'
#           'alpha:bravo:charlie'
#           'bravo:alpha'
#           'bravo:bravo'
#           'bravo:charlie does something'
#           'delta:bravo:alpha does something else'
#           'delta:bravo:echo'
#           'echo:delta'
#         ]
#
#       t.deepEqual getCommandHelpLinesFromLifetime(lifetime, 'bravo'),
#         [
#           'bravo:alpha'
#           'bravo:bravo'
#           'bravo:charlie does something'
#         ]
#
#       t.deepEqual getCommandHelpLinesFromLifetime(lifetime, 'delta', 'bravo'),
#         [
#           'delta:bravo:alpha does something else'
#           'delta:bravo:echo'
#         ]
#
#       t.deepEqual getCommandHelpLinesFromLifetime(lifetime, 'delta:bravo'),
#         [
#           'delta:bravo:alpha does something else'
#           'delta:bravo:echo'
#         ]
#
#       t.deepEqual getCommandHelpLinesFromLifetime(lifetime, 'echo:delta'),
#         [
#           'echo:delta'
#         ]
#       t.end()

test 'start and stop default server', (t) ->
  example (
    command_serve
    fragments_shutdown
  ) ->
    command_serve()
      .then ->
        fragments_shutdown()
      .then ->
        t.end()

test 'start and stop custom server', (t) ->
  example (
    command_serve
    shutdown
  ) ->
    command_serve('helloWorldServer')
      .then ->
        shutdown()
      .then ->
        t.end()
