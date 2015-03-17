module.exports.fragments_$meta = ->
  []

module.exports.fragments_getMeta = (fragments_$meta) ->
  ->
    fragments_$meta

module.exports.fragments_pushMeta = (fragments_$meta) ->
  (attrs) ->
    fragments_$meta.push attrs

