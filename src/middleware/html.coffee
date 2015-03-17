CAMELCASED_STATUS_CODES = require '../status-codes'

################################################################################
# kup

module.exports.fragments_k = (
  fragments_kup
) ->
  new fragments_kup

module.exports.fragments_

module.exports.fragments_endKup = (
  fragments_endHTML
  fragments_k
) ->
  ->
    fragments_endHTML fragments_k.htmlOut

################################################################################
# react + kup layout

module.exports.fragments_endReactWithLayout = (
  fragments_k
  fragments_endKup
) ->
  (layoutFunc, rest...) ->
    layoutFunc ->
      fragments_k.react rest...
    fragments_endKup()

################################################################################
# respond with status code and kup, react with layout
# example: end404Kup(), endNotFoundReactKup(component),
# endUnprocessableReact(component) and all other imaginable combinations...

[
  'Kup'
  'ReactWithLayout'
].forEach (content) ->
  for statusCode, camelcasedName of CAMELCASED_STATUS_CODES
    do (statusCode, camelcasedName) ->
      factory = (
        fragments_setStatus
        endX
      ) ->
        (args...) ->
          fragments_setStatus statusCode
          endX args...
      factory.$inject = ['fragments_setStatus', "fragments_end#{content}"]
      # numeric status code
      module.exports["fragments_end#{statusCode}#{content}"] = factory
      # textual status code
      module.exports["fragments_end#{camelcasedName}#{content}"] = factory
