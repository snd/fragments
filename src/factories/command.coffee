module.exports.fragments_commandPrefix = ->
  'command_'

module.exports.fragments_getCommandNamesFromLifetime = (
  fragments_helfer
  fragments_commandPrefix
) ->
  (lifetime) ->
    Object.keys(lifetime.factories)
      .filter (x) -> x.indexOf(fragments_commandPrefix) is 0
      .map (x) -> x.slice(fragments_commandPrefix.length)
      .map fragments_helfer.camelSnakeToHyphenColon

module.exports.fragments_commandNameToFactoryPropertyName = (
  fragments_helfer
  fragments_commandPrefix
) ->
  (name) ->
    fragments_commandPrefix + fragments_helfer.hyphenColonToCamelSnake(name)

module.exports.fragments_getCommandInLifetime = (
  fragments_Promise
  fragments_hinoki
  fragments_commandNameToFactoryPropertyName
  fragments_source
) ->
  (lifetime, commandName) ->
    unless commandName?
      commandName = 'help'

    commandName = commandName.toLowerCase()
    commandKey = fragments_commandNameToFactoryPropertyName(commandName)
    commandFactory = fragments_source(commandKey)

    unless commandFactory?
      return

    (args...) ->
      fragments_hinoki(fragments_source, lifetime, commandKey).then (commandInstance) ->
        commandInstance args...

module.exports.fragments_runCommand = (
  fragments_getCommandInLifetime
  fragments_applicationLifetime
) ->
  (commandName, args...) ->
    command = fragments_getCommandInLifetime(
      fragments_applicationLifetime
      commandName
    )
    if command?
      command args...
    else
      throw new Error "no such command: #{commandName}"

module.exports.fragments_getCommandHelpLinesFromLifetime = (
  fragments_getCommandNamesFromLifetime
  fragments_commandNameToFactoryPropertyName
  fragments_isjs
  fragments_lodash
) ->
  (lifetime, args...) ->
    _ = fragments_lodash
    commandNames = fragments_getCommandNamesFromLifetime(lifetime)
    # help for a specific command or namespace is requested
    if args.length isnt 0
      prefix = args.join(':')
      commandNames = _.filter commandNames, (name) ->
        fragments_isjs.startWith name, prefix

    commandNames = _.sortBy(commandNames)

    commandNames.map (name) ->
      key = fragments_commandNameToFactoryPropertyName name
      line = name
      docstring = lifetime.factories[key].$help
      if docstring?
        line += ' ' + docstring
      return line

module.exports.command_help = (
  fragments_getCommandHelpLinesFromLifetime
  fragments_applicationLifetime
) ->
  (args...) ->
    fragments_getCommandHelpLinesFromLifetime(fragments_applicationLifetime, args...).forEach (line) ->
      console.log line
module.exports.command_help.$help = '[namespace-prefixes...] display available commands'

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
            console.log 'shutting down server by calling server.close()'
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

module.exports.command_serve.$help = "[server-callback-name (default: 'server')] - start a server with server-callback-name as callback"

module.exports.command_info = (
  fragments_APPLICATION
) ->
  fragments_APPLICATION (
    fragments_console
  ) ->
    (args...) ->
      fragments_console.log 'TODO'
      fragments_console.log 'OK'
