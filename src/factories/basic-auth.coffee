module.exports.fragments_endUnauthorizedRequiresBasicAuth = (
  fragments_setHeaderWWWAuthenticate
  fragments_endUnauthorized
) ->
  (args...) ->
    fragments_setHeaderWWWAuthenticate 'basic realm="secure area"'
    fragments_endUnauthorized args...

module.exports.fragments_basicAuthCredentials = (
  fragments_req
  fragments_basicAuth
) ->
  # {name: ..., pass: ...}
  fragments_basicAuth(fragments_req) or null
