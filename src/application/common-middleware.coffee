module.exports.fragments_commonMiddlewarePrelude = (
  fragments_sequenz

  fragments_config_staticPath

  fragments_expressCompression
  fragments_expressServeStatic
  fragments_expressBodyParser
  fragments_expressCookieParser
  fragments_queryParser
) ->
  fragments_sequenz [
    fragments_expressCompression()
    fragments_expressServeStatic(fragments_config_staticPath)
    fragments_expressBodyParser.urlencoded({extended: true})
    fragments_expressBodyParser.json()
    fragments_queryParser()
    fragments_expressCookieParser()
  ]
