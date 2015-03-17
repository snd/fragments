module.exports.fragments_kupToHtml = (fragments_kup) ->
  (f) ->
    k = new fragments_kup
    f k
    k.htmlOut

module.exports.fragments_reactKupToHtml = (
  fragments_react
  fragments_reactComponentToHtml
) ->
  (f) ->
    fragments_react.renderToStaticMarkup fragments_react.kup f

module.exports.fragments_reactToHtml = (
  fragments_react
) ->
  (elementOrComponent, rest...) ->
    element =
      if fragments_react.isValidElement elementOrComponent
        elementOrComponent
      else
        fragments_react.createElement elementOrComponent, rest...
    fragments_react.renderToStaticMarkup element
