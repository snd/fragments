path = require 'path'
fs = require 'fs'

hinoki = require 'hinoki'
_ = require 'lodash'

################################################################################
# load

# returns an object containing all the exported properties
# of all `*.js` and `*.coffee` files in `filepath`.
# if `filepath` is a directory recurse into every file and subdirectory.
# throws if a property is not a function (only accepts functions).
# throws if a property occurs in more than one file.

module.exports.loadFactories = loadFactories = (arg1, arg2) ->
  if arg2?
    object = arg1
    filepath = arg2
  else
    object = {}
    filepath = arg1

  unless 'string' is typeof filepath
    throw new Error "`filepath` argument must be a string but is type = `#{typeof filepath}` value = `#{filepath}`"

  unless 'object' is typeof object
    throw new Error "`object` argument must be a string but is type = `#{typeof object}` value = `#{object}`"

  stat = fs.statSync(filepath)
  if stat.isFile()
    ext = path.extname(filepath)

    if ext isnt '.js' and ext isnt '.coffee'
      return

    # coffeescript is only required on demand when the project contains .coffee files
    # in order to support pure javascript projects
    if ext is '.coffee'
      require('coffee-script/register')

    exp = require(filepath)

    Object.keys(exp).map (key) ->
      unless 'function' is typeof exp[key]
        throw new Error('export is not a function: ' + key + ' in :' + filepath)
      if object[key]?
        throw new Error('duplicate export: ' + key + ' in: ' + filepath + '. first was in: ' + object[key].$file)
      object[key] = exp[key]
      # add filename as metadata
      object[key].$file = filepath

  else if stat.isDirectory()
    filenames = fs.readdirSync(filepath)
    filenames.forEach (filename) ->
      loadFactories object, path.join(filepath, filename)

  return object

################################################################################
# string case conversion

# camelToSnake('camelCase') -> 'camel_case'
module.exports.camelToSnake = camelToSnake = (string) ->
  string.replace /([a-z][A-Z])/g, (m) -> m[0] + '_' + m[1].toLowerCase()

# snakeToCamel('snake_case') -> 'snakeCase'
module.exports.snakeToCamel = snakeToCamel = (string) ->
  string.replace /_([a-z])/g, (m) -> m[1].toUpperCase()

# camelToHyphen('camelCase') -> 'camel-case
module.exports.camelToHyphen = camelToHyphen = (string) ->
  string.replace /([a-z][A-Z])/g, (m) -> m[0] + '-' + m[1].toLowerCase()

# hyphenToCamel('hyphen-delimited') -> 'hyphenDelimited'
module.exports.hyphenToCamel = hyphenToCamel = (string) ->
  string.replace /-([a-z])/g, (m) -> m[1].toUpperCase()

# colonToSnake('colon:delimited') -> 'colon_delimited'
module.exports.colonToSnake = colonToSnake = (string) ->
  string.replace /:/g, '_'

# snakeToColon('snake_case') -> 'snake:case'
module.exports.snakeToColon = snakeToColon = (string) ->
  string.replace /_/g, ':'

# hyphenColonToCamelSnake('hyphen:colon-to:camel-snake') -> 'hyphen_colonTo_camelSnake'
module.exports.hyphenColonToCamelSnake = hyphenColonToCamelSnake = (string) ->
  hyphenToCamel(colonToSnake(string))

# camelSnakeToHyphenColon('camel_snakeTo_hyphenColon') -> 'camel:snake-to:hyphen-colon'
module.exports.camelSnakeToHyphenColon = camelSnakeToHyphenColon = (string) ->
  camelToHyphen(snakeToColon(string))

################################################################################
# namespace resolver

# super fast namespace resolver
module.exports.namespaceResolver = (name, lifetime, inner) ->
  result = inner name
  if result?
    result
  else
    inner 'fragments_' + name

################################################################################
# command runner

module.exports.COMMAND_PREFIX = 'command_'

module.exports.getCommandNamesFromLifetime = getCommandNamesFromLifetime = (lifetime) ->
  Object.keys(lifetime.factories)
    .filter (x) -> x.indexOf(module.exports.COMMAND_PREFIX) is 0
    .map (x) -> x.slice(module.exports.COMMAND_PREFIX.length)
    .map camelSnakeToHyphenColon

module.exports.commandNameToKey = commandNameToKey = (name) ->
  module.exports.COMMAND_PREFIX + hyphenColonToCamelSnake(name)

# run a command from the factories in the lifetime
module.exports.runCommand = (lifetime, commandName, arg, args...) ->
  if commandName?
    commandName = commandName.toLowerCase()

  if not commandName? or commandName is 'help'
    console.log 'available commands:'
    getCommandNamesFromLifetime(lifetime).forEach (name) ->
      key = commandNameToKey name
      help = lifetime.factories[key].$help
      console.log name + if help then ' - ' + help else ''

    # TODO show $help property of command factory
    # TODO help for specific command
  else
    commandKey = commandNameToKey commandName
    commandFactory = lifetime.factories[commandKey]

    if commandFactory?
      hinoki.get(lifetime, commandKey).then (commandInstance) ->
        commandInstance arg, args...
    else
      throw new Error "unrecognized command: #{commandName}"

################################################################################
# sources

# module.exports.defaultShadowWarnings = ->
#   console.log "WARNING: user defined process factory for `#{key}` from file #{factory.$file} overrides fragments factory"
#
# module.exports.defaultOverrideWarnings = ->

module.exports.toSources = toSources = (value) ->
  if not value?
    []
  else if Array.isArray value
    _.flatten value
  else
    [value]

module.exports.sourcesToFactories = sourcesToFactories = (sources, overrideWarnings) ->
  reducer = (existingFactories, value) ->
    additionalFactories =
      if 'string' is typeof value
        loadFactories value
      else if 'object' is typeof value
        value
      else
        throw new Error 'source must be a filename, directory name or an object'
    _.each additionalFactories, (value, key) ->
      if overrideWarnings? and existingFactories[key]?
        overrideWarnings key, existingFactories[key], value
      existingFactories[key] = value
    return existingFactories
  sources.reduce reducer, {}

################################################################################
# default warnings

# module.exports.defaultShadowWarnings = ->
#   console.log "WARNING: user defined application factory for `#{key}` from file #{factory.$file} overrides fragments factory"

# module.exports.defaultOverrideWarnings = ->

################################################################################
# fragments factories

module.exports.init = init = loadFactories __dirname + '/init'
module.exports.application = application = loadFactories __dirname + '/application'
module.exports.request = request = loadFactories __dirname + '/request'
module.exports.middleware = middleware = loadFactories __dirname + '/middleware'

_.each init, (f) -> f.$source = 'fragments.init'
_.each application, (f) -> f.$source = 'fragments.application'
_.each request, (f) -> f.$source = 'fragments.request'
_.each middleware, (f) -> f.$source = 'fragments.middleware'

################################################################################
# public

module.exports.configure = (options = {}) ->
  shadowWarnings =
    if options.shadowWarnings?
      if 'function' is typeof options.shadowWarnings
        options.shadowWarnings
      else
        module.exports.defaultShadowWarnings
  options.overrideWarnings =
    if options.overrideWarnings?
      if 'function' is typeof options.overrideWarnings
        options.overrideWarnings
      else
        module.exports.defaultOverrideWarnings

  # normalize sources
  sources =
    init: toSources options.init
    application: toSources options.application
    request: toSources options.request
    middleware: toSources options.middleware

  # add fragments factories as the first source
  sources.init.unshift init
  sources.application.unshift application
  sources.request.unshift request
  sources.middleware.unshift middleware

  # load factories from all sources
  factories = _.mapValues sources, (source) ->
    sourcesToFactories source, options.overrideWarnings

  if shadowWarnings?
    _.each factories.request, (value, key) ->
      if factories.process[key]?
        shadowWarnings key, factories.process[key], value

    _.each factories.middleware, (value, key) ->
      if factories.request[key]?
        shadowWarnings key, factories.request[key], value
      if factories.process[key]?
        shadowWarnings key, factories.process[key], value

  InitLifetime = ->
    this.values =
      applicationFactories: factories.application
      requestFactories: factories.request
      middlewareFactories: factories.middleware
      namespaceResolver: module.exports.namespaceResolver
    return this

  InitLifetime.prototype.factories = factories.init

  {
    factory: (factory) ->
      initLifetime = new InitLifetime
      hinoki.get(initLifetime, 'applicationLifetime')
        .then (applicationLifetime) ->
          hinoki.get(applicationLifetime, 'fragments_APPLICATION')
        .then (APPLICATION) ->
          APPLICATION factory
    command: (args...) ->
      initLifetime = new InitLifetime
      hinoki.get(initLifetime, 'applicationLifetime')
        .then (applicationLifetime) ->
          module.exports.runCommand applicationLifetime, args...
  }
