CAMELCASED_STATUS_CODES = require '../status-codes'

module.exports.fragments_kupToHtml = (fragments_kup) ->
  (f) ->
    k = new fragments_kup
    f k
    k.htmlOut

module.exports.fragments_reactKupToHtml = (
  fragments_react
  fragments_reactDomServer
) ->
  (f) ->
    fragments_reactDomServer.renderToStaticMarkup fragments_react.kup f

module.exports.fragments_reactToHtml = (
  fragments_react
  fragments_reactDomServer
) ->
  (elementOrComponent, rest...) ->
    element =
      if fragments_react.isValidElement elementOrComponent
        elementOrComponent
      else
        fragments_react.createElement elementOrComponent, rest...
    fragments_reactDomServer.renderToStaticMarkup element

module.exports.fragments_endHTML = (
  fragments_setHeaderContentTypeHTML
  fragments_end
) ->
  (args...) ->
    fragments_setHeaderContentTypeHTML()
    fragments_end args...

module.exports.fragments_endReact = (
  fragments_reactToHtml
  fragments_endHTML
) ->
  (args...) ->
    fragments_endHTML fragments_reactToHtml args...

################################################################################
# kup

module.exports.fragments_k = (
  # force this to be in the middleware lifetime
  fragments_next
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
      factory.__inject = ['fragments_setStatus', "fragments_end#{content}"]
      # numeric status code
      module.exports["fragments_end#{statusCode}#{content}"] = factory
      # textual status code
      module.exports["fragments_end#{camelcasedName}#{content}"] = factory
