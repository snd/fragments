module.exports.fragments_commandPrefix = ->
  'command_'

module.exports.fragments_getCommandNamesFromLifetime = (
  fragments_camelSnakeToHyphenColon
  fragments_commandPrefix
) ->
  (lifetime) ->
    Object.keys(lifetime.factories)
      .filter (x) -> x.indexOf(fragments_commandPrefix) is 0
      .map (x) -> x.slice(fragments_commandPrefix.length)
      .map fragments_camelSnakeToHyphenColon

module.exports.fragments_commandNameToFactoryPropertyName = (
  fragments_commandPrefix
  fragments_hyphenColonToCamelSnake
) ->
  (name) ->
    fragments_commandPrefix + fragments_hyphenColonToCamelSnake(name)

module.exports.fragments_getCommandInLifetime = (
  fragments_Promise
  fragments_hinoki
  fragments_commandNameToFactoryPropertyName
) ->
  (lifetime, commandName) ->
    unless commandName?
      commandName = 'help'

    commandName = commandName.toLowerCase()

    commandKey = fragments_commandNameToFactoryPropertyName commandName
    commandFactory = lifetime.factories[commandKey]

    unless commandFactory?
      return

    (args...) ->
      fragments_hinoki.get(lifetime, commandKey).then (commandInstance) ->
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
      Promise
      http
      onShutdown
      shutdownBefore
      console
      port
      baseUrl
      serverCallback
    ) ->
      return new Promise (resolve, reject) ->
        server = http.createServer serverCallback
        server.on 'listening', ->
          onShutdown 'server', ->
            console.log 'shutting down server by calling server.close()'
            Promise.promisify(server.close, server)()
          # shutdown postgres and redis before server to prevent server from crashing
          # when they are already stopped and the server is still trying to use them
          shutdownBefore 'postgres', 'server'
          shutdownBefore 'redis', 'server'
          console.log "go visit #{baseUrl}"
          console.log 'OK'
          resolve()
        server.on 'error', reject
        server.listen port

    factory.$inject = [
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

module.exports.command_pg_migrate = (
  fragments_APPLICATION
) ->
  fragments_APPLICATION (
    fragments_console
    fragments_pgMigrate
    fragments_shutdown
    fragments_Promise
  ) ->
    (args...) ->
      isVerbose = '--verbose' in args
      isDry = '--dry'in args

      fragments_pgMigrate(isVerbose, isDry)
        .catch (err) ->
          fragments_console.log 'shutting down because of error:', err
          fragments_shutdown().then ->
            fragments_Promise.reject err
        .then ->
          fragments_shutdown()
        .then ->
          fragments_console.log 'OK'
module.exports.command_pg_migrate.$help = '[--verbose] [--dry] - migrate'

module.exports.command_migrations_create = (
  fragments_APPLICATION
) ->
  fragments_APPLICATION (
    fragments_console
    fragments_fs
    fragments_path
    fragments_moment
    fragments_config_migrationPath
    fragments_Promise
  ) ->
    (name) ->
      unless name?
        fragments_console.log 'Usage: ... migrations:create {migration-name}'
        return

      time = fragments_moment().format('YYYYMMDDHHmmss')
      filename = "#{time}-#{name}.sql"
      filepath = fragments_path.join(fragments_config_migrationPath, filename)
      fragments_console.log(filepath)

      # make sure the migration path is present
      fragments_fs.mkdirAsync(fragments_config_migrationPath)
        .catch (err) ->
          if err.cause.code isnt 'EEXIST'
            fragments_Promise.reject err
        .then ->
          fragments_fs.writeFileAsync(filepath, '')
        .then ->
          fragments_console.log 'OK'
module.exports.command_migrations_create.$help = '{migration-name}'

module.exports.command_pg_create = (
  fragments_APPLICATION
) ->
  fragments_APPLICATION (
    fragments_console
    fragments_pgCreate
    fragments_shutdown
    fragments_Promise
  ) ->
    ->
      fragments_pgCreate()
        .catch (err) ->
          fragments_console.log 'shutting down because of error:', err
          fragments_shutdown().then ->
            fragments_Promise.reject err
        .then ->
          fragments_shutdown()
        .then ->
          fragments_console.log 'OK'

module.exports.command_pg_drop = (
  fragments_APPLICATION
) ->
  fragments_APPLICATION (
    fragments_console
    fragments_pgDrop
    fragments_shutdown
    fragments_Promise
  ) ->
    ->
      fragments_pgDrop()
        .catch (err) ->
          fragments_console.log 'shutting down because of error:', err
          fragments_shutdown().then ->
            fragments_Promise.reject err
        .then ->
          fragments_shutdown()
        .then ->
          fragments_console.log 'OK'

module.exports.command_pg_dropCreate = (
  fragments_APPLICATION
) ->
  fragments_APPLICATION (
    fragments_console
    fragments_pgDropCreate
    fragments_shutdown
    fragments_Promise
  ) ->
    ->
      fragments_pgDropCreate()
        .catch (err) ->
          fragments_console.log 'shutting down because of error:', err
          fragments_shutdown().then ->
            fragments_Promise.reject err
        .then ->
          fragments_shutdown()
        .then ->
          fragments_console.log 'OK'

module.exports.command_pg_dropCreateMigrate = (
  fragments_APPLICATION
) ->
  fragments_APPLICATION (
    fragments_console
    fragments_pgDropCreateMigrate
    fragments_shutdown
    fragments_Promise
  ) ->
    ->
      fragments_pgDropCreateMigrate()
        .catch (err) ->
          fragments_console.log 'shutting down because of error:', err
          fragments_shutdown().then ->
            fragments_Promise.reject err
        .then ->
          fragments_shutdown()
        .then ->
          fragments_console.log 'OK'
