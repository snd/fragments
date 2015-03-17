module.exports.fragments_redirect = (
  fragments_setHeaderLocation
  fragments_endMovedTemporarily
) ->
  (location) ->
    fragments_setHeaderLocation location
    fragments_endMovedTemporarily()

module.exports.fragments_redirectToReferer = (
  fragments_redirect
  fragments_headerReferer
  fragments_url
) ->
  ->
    # default to request url if no referer header
    fragments_redirect (fragments_headerReferer or fragments_url)
