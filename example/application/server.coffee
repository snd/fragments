module.exports.commonMiddleware = (
  sequenz

  envStringStaticPath

  expressCompression
  expressServeStatic
  expressBodyParser
  expressCookieParser
  queryParser
) ->
  sequenz [
    expressCompression()

    expressServeStatic(envStringStaticPath)

    expressBodyParser.urlencoded({extended: true})
    expressBodyParser.json()

    queryParser()

    expressCookieParser()
  ]

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
  commonMiddleware

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
) ->
  sequenz [
    commonMiddleware

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

    MIDDLEWARE (endNotFound) ->
      endNotFound()
  ]
