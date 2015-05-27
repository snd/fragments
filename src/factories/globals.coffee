# defaults

module.exports.fragments_process = ->
  process

module.exports.fragments_console = ->
  console

module.exports.fragments_argv = (fragments_process) ->
  fragments_process.argv
