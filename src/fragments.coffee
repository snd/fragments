hinoki = require 'hinoki'
_ = require 'lodash'

module.exports = (arg) ->
  source = if arg then hinoki.source arg else module.exports.source

  result = (factory) ->
    applicationLifetime = {}
    applicationLifetime.fragments_applicationLifetime = applicationLifetime
    applicationLifetime.fragments_source = source

    hinoki source, applicationLifetime, (fragments_APPLICATION) ->
      fragments_APPLICATION factory

  result.runCommand = (args) ->
    unless args?
      args = process.argv.slice(2)

    applicationLifetime = {}
    applicationLifetime.fragments_applicationLifetime = applicationLifetime
    applicationLifetime.fragments_source = source

    hinoki source, applicationLifetime, (fragments_runCommand) ->
      fragments_runCommand args...

  return result

module.exports.source = hinoki.source(__dirname + '/factories')
