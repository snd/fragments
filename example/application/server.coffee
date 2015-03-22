module.exports.helloWorldServer = (
  MIDDLEWARE
  sequenz
) ->
  sequenz [
    MIDDLEWARE (
      end
    ) ->
      end 'Hello World'
  ]

module.exports.server = (
  MIDDLEWARE

  sequenz
  commonMiddlewarePrelude

  route_echo
  route_error
  route_method
  route_any
  route_redirect
  route_text
  route_json
  route_xml
  route_kup
  route_react
  route_reactKup
  route_sessionSet
  route_sessionGet
) ->
  sequenz [
    commonMiddlewarePrelude

    route_echo
    route_error
    route_method
    route_any
    route_redirect
    route_text
    route_json
    route_xml
    route_kup
    route_react
    route_reactKup
    route_sessionSet
    route_sessionGet

    MIDDLEWARE (endNotFound) ->
      endNotFound()
  ]
