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

loadFactories = (arg1, arg2) ->
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
# namespace resolver

# super fast namespace resolver
namespaceResolver = (name, lifetime, inner) ->
  result = inner name
  if result?
    result
  else
    inner 'fragments_' + name

################################################################################
# sources

# module.exports.defaultShadowWarnings = ->
#   console.log "WARNING: user defined process factory for `#{key}` from file #{factory.$file} overrides fragments factory"
#
# module.exports.defaultOverrideWarnings = ->

toSources = (value) ->
  if not value?
    []
  else if Array.isArray value
    _.flatten value
  else
    [value]

sourcesToFactories = (sources, overrideWarnings) ->
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
# fragments factories

init = loadFactories __dirname + '/init'
application = loadFactories __dirname + '/application'
request = loadFactories __dirname + '/request'
middleware = loadFactories __dirname + '/middleware'

_.each init, (f) -> f.$source = 'fragments.init'
_.each application, (f) -> f.$source = 'fragments.application'
_.each request, (f) -> f.$source = 'fragments.request'
_.each middleware, (f) -> f.$source = 'fragments.middleware'

################################################################################
# public

module.exports = (options = {}) ->
  # shadowWarnings =
  #   if options.shadowWarnings?
  #     if 'function' is typeof options.shadowWarnings
  #       options.shadowWarnings
  #     else
  #       module.exports.defaultShadowWarnings
  # options.overrideWarnings =
  #   if options.overrideWarnings?
  #     if 'function' is typeof options.overrideWarnings
  #       options.overrideWarnings
  #     else
  #       module.exports.defaultOverrideWarnings

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
      namespaceResolver: namespaceResolver
    return this

  InitLifetime.prototype.factories = factories.init

  result = (factory) ->
    initLifetime = new InitLifetime
    hinoki(initLifetime, 'applicationLifetime')
      .then (applicationLifetime) ->
        hinoki(applicationLifetime, 'fragments_APPLICATION')
      .then (APPLICATION) ->
        APPLICATION factory

  result.runCommand = (args) ->
    unless args?
      args = process.argv.slice(2)
    initLifetime = new InitLifetime
    hinoki(initLifetime, 'applicationLifetime')
      .then (applicationLifetime) ->
        hinoki(applicationLifetime, 'fragments_runCommand')
      .then (runCommand) ->
        runCommand args...

  return result
