module.exports.fragments_write = (
  fragments_res
) ->
  (args...) ->
    fragments_res.write args...

module.exports.fragments_end = (
  fragments_res
) ->
  (args...) ->
    fragments_res.end args...

module.exports.fragments_endJSON = (
  fragments_endNotFound
  fragments_setHeaderContentTypeJSON
  fragments_end
) ->
  (object) ->
    fragments_setHeaderContentTypeJSON()
    fragments_end JSON.stringify(object)

module.exports.fragments_endXML = (
  fragments_endNotFound
  fragments_setHeaderContentTypeXML
  fragments_end
) ->
  (args...) ->
    fragments_setHeaderContentTypeXML()
    fragments_end args...

module.exports.fragments_endText = (
  fragments_setHeaderContentTypeText
  fragments_end
) ->
  (args...) ->
    fragments_setHeaderContentTypeText()
    fragments_end args...
