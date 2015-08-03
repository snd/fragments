module.exports.actionEcho = (ANY) ->
  ANY '/echo', (
    endJSON
    method
    req
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
      url: req.url
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

module.exports.actionError = (GET) ->
  GET '/error', (
  ) ->
    throw new Error 'TESTING ERRORS: this is supposed to get thrown and logged'

module.exports.actionMethod = (
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

module.exports.actionAny = (
  ANY
) ->
  ANY '/any', (
    method
    end
  ) ->
    end "method is #{method}"

module.exports.actionRedirect = (GET) ->
  GET '/redirect', (
    redirect
  ) ->
    console.log 'REDIRECTING'
    redirect '/redirect-target'

module.exports.actionRedirectTarget = (GET) ->
  GET '/redirect-target', (
    endText
  ) ->
    endText 'you made it'

module.exports.actionText = (GET) ->
  GET '/text', (
    endText
  ) ->
    endText 'Hello World'

module.exports.actionJson = (GET) ->
  GET '/json', (
    endUnprocessableJSON
  ) ->
    endUnprocessableJSON {a: 1}

module.exports.actionXml = (GET) ->
  GET '/xml', (
    end429XML
  ) ->
    end429XML '<test></test>'

module.exports.actionKup = (GET) ->
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

module.exports.actionReact = (GET) ->
  GET '/react', (
    ComponentContent
    endReact
    react
  ) ->
    endReact react.createElement ComponentContent

module.exports.actionReactKup = (GET) ->
  GET '/react-kup', (
    ComponentContent
    end404ReactWithLayout
    layout
  ) ->
    end404ReactWithLayout layout, ComponentContent

module.exports.actionSessionGet = (GET) ->
  GET '/session', (
    session
    endJSON
  ) ->
    endJSON session

module.exports.actionSessionSet = (PATCH) ->
  PATCH '/session', (
    session
    body
    endJSON
    _
  ) ->
    _.extend session, body
    endJSON session

module.exports.actionSessionDelete = (DELETE) ->
  DELETE '/session', (
    session
    end
  ) ->
    session.destroy ->
      end()

module.exports.actionTokenCreate = (POST) ->
  POST '/token', (
    newJwt
    body
    endJSON
  ) ->
    endJSON {token: newJwt(body)}

module.exports.actionTokenRead = (GET) ->
  GET '/token', (
    token
    endJSON
  ) ->
    endJSON token
