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
