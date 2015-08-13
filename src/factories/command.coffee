module.exports.fragments_commandPrefix = ->
  'command_'

module.exports.fragments_getCommandNames = (
  fragments_helfer
  fragments_commandPrefix
  fragments_source
) ->
  ->
    keys = fragments_source.keys?() or []
    keys
      .filter (x) -> x.indexOf(fragments_commandPrefix) is 0
      .map (x) -> x.slice(fragments_commandPrefix.length)
      .map fragments_helfer.camelSnakeToHyphenColon

module.exports.fragments_commandNameToKey = (
  fragments_helfer
  fragments_commandPrefix
) ->
  (name) ->
    fragments_commandPrefix + fragments_helfer.hyphenColonToCamelSnake(name)

module.exports.fragments_getCommand = (
  fragments_Promise
  fragments_hinoki
  fragments_commandNameToKey
  fragments_source
  fragments_applicationLifetime
) ->
  (commandName) ->
    commandKey = fragments_commandNameToKey(commandName.toLowerCase())
    commandFactory = fragments_source(commandKey)

    unless commandFactory?
      return

    (args...) ->
      fragments_hinoki(fragments_source, fragments_applicationLifetime, commandKey)
        .then (commandInstance) ->
          commandInstance args...

module.exports.fragments_runCommand = (
  fragments_getCommand
  fragments_source
) ->
  (commandName, args...) ->
    unless commandName?
      commandName = 'help'
    command = fragments_getCommand(commandName)
    if command?
      command args...
    else
      throw new Error "no such command: #{commandName}"

module.exports.fragments_getCommandHelpLines = (
  fragments_getCommandNames
  fragments_commandNameToKey
  fragments_isjs
  fragments_lodash
  fragments_source
) ->
  (args...) ->
    _ = fragments_lodash
    commandNames = fragments_getCommandNames()
    # help for a specific command or namespace is requested
    if args.length isnt 0
      prefix = args.join(':')
      commandNames = _.filter commandNames, (name) ->
        fragments_isjs.startWith name, prefix

    commandNames = _.sortBy(commandNames)

    commandNames.map (name) ->
      key = fragments_commandNameToKey name
      line = name
      factory = fragments_source(key)
      docstring = factory.__help
      if docstring?
        line += ' ' + docstring
      return line

module.exports.command_help = (
  fragments_getCommandHelpLines
) ->
  (args...) ->
    fragments_getCommandHelpLines(args...).forEach (line) ->
      console.log line
module.exports.command_help.__help = '[namespace-prefixes...] display available commands'

module.exports.command_serve = (
  fragments_APPLICATION
) ->
  (serverCallbackName = 'server') ->
    factory = (
      fragments_Promise
      fragments_http
      fragments_onShutdown
      fragments_shutdownBefore
      fragments_console
      fragments_config_port
      fragments_config_baseUrl
      serverCallback
    ) ->
      return new fragments_Promise (resolve, reject) ->
        server = fragments_http.createServer serverCallback
        server.on 'listening', ->
          fragments_onShutdown 'server', ->
            fragments_console.log 'shutting down server by calling server.close()'
            fragments_Promise.promisify(server.close, server)()
          # shutdown postgres and redis before server to prevent server from crashing
          # when they are already stopped and the server is still trying to use them
          fragments_shutdownBefore 'postgres', 'server'
          fragments_shutdownBefore 'redis', 'server'
          fragments_console.log "go visit #{fragments_config_baseUrl}"
          fragments_console.log 'OK'
          resolve()
        server.on 'error', reject
        server.listen fragments_config_port

    factory.__inject = [
      'fragments_Promise'
      'fragments_http'
      'fragments_onShutdown'
      'fragments_shutdownBefore'
      'fragments_console'
      'fragments_config_port'
      'fragments_config_baseUrl'
      serverCallbackName
    ]
    fragments_APPLICATION factory

module.exports.command_serve.__help = "[server-callback-name (default: 'server')] - start a server with `server-callback-name` as callback"
