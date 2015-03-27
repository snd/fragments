module.exports.route_echo = (GET) ->
  GET '/echo', (
    endJSON
    method
    url
    urlWithoutQuerystring
    query
    body
    userAgent
    ip
    isGzipEnabled
    matchCurrentUrl
    basicAuthCredentials
    session
    token
  ) ->
    endJSON
      method: method
      url: url
      urlWithoutQuerystring: urlWithoutQuerystring
      query: query
      body: body
      userAgent: userAgent
      ip: ip
      isGzipEnabled: isGzipEnabled()
      match: matchCurrentUrl('/:part')
      alsoMatch: matchCurrentUrl('/echo')
      noMatch: matchCurrentUrl('/echo/:id')
      basicAuthCredentials: basicAuthCredentials
      session: session
      token: token

module.exports.route_error = (GET) ->
  GET '/error', (
  ) ->
    throw new Error 'TESTING ERRORS: this is supposed to get thrown and logged'

module.exports.route_method = (
  GET
  PUT
  POST
  DELETE
  PATCH
  sequenz
) ->
  url = '/method'
  sequenz(
    GET url, (end) -> end 'get'
    POST url, (end) -> end 'post'
    PUT url, (end) -> end 'put'
    PATCH url, (end) -> end 'patch'
    DELETE url, (end) -> end 'delete'
  )

module.exports.route_any = (
  ANY
) ->
  ANY '/any', (
    method
    end
  ) ->
    end "method is #{method}"

module.exports.route_redirect = (GET) ->
  GET '/redirect', (
    redirect
  ) ->
    redirect '/go-here'

module.exports.route_text = (GET) ->
  GET '/text', (
    endText
  ) ->
    endText 'Hello World'

module.exports.route_json = (GET) ->
  GET '/json', (
    endUnprocessableJSON
  ) ->
    endUnprocessableJSON {a: 1}

module.exports.route_xml = (GET) ->
  GET '/xml', (
    end429XML
  ) ->
    end429XML '<test></test>'

module.exports.route_kup = (GET) ->
  GET '/kup', (
    layout
    k
    endKup
    pushMeta
    $meta
  ) ->
    pushMeta
      name: "robots"
      content: "index,follow"
    pushMeta
      name: "keywords"
      content: "test"
    layout ->
      k.span 'content'
    endKup()

module.exports.route_react = (GET) ->
  GET '/react', (
    ComponentContent
    endReact
    react
  ) ->
    endReact react.createElement ComponentContent

module.exports.route_reactKup = (GET) ->
  GET '/react-kup', (
    ComponentContent
    end404ReactWithLayout
    layout
  ) ->
    end404ReactWithLayout layout, ComponentContent

module.exports.route_sessionGet = (GET) ->
  GET '/session', (
    session
    endJSON
  ) ->
    endJSON session

module.exports.route_sessionSet = (PATCH) ->
  PATCH '/session', (
    session
    body
    endJSON
    _
  ) ->
    _.extend session, body
    endJSON session

module.exports.route_sessionDelete = (DELETE) ->
  DELETE '/session', (
    session
    end
  ) ->
    session.destroy ->
      end()

module.exports.route_tokenCreate = (POST) ->
  POST '/token', (
    newJwt
    body
    endJSON
  ) ->
    endJSON {token: newJwt(body)}

module.exports.route_tokenRead = (GET) ->
  GET '/token', (
    token
    endJSON
  ) ->
    endJSON token
