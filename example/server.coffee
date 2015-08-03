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
  autoHeadersMiddleware

  actionEcho
  actionError
  actionMethod
  actionAny
  actionRedirect
  actionRedirectTarget
  actionText
  actionJson
  actionXml
  actionKup
  actionReact
  actionReactKup
  actionSessionSet
  actionSessionGet
  actionSessionDelete
  actionTokenCreate
  actionTokenRead
) ->
  sequenz [
    commonMiddlewarePrelude
    autoHeadersMiddleware

    actionEcho
    actionError
    actionMethod
    actionAny
    actionRedirect
    actionRedirectTarget
    actionText
    actionJson
    actionXml
    actionKup
    actionReact
    actionReactKup
    actionSessionSet
    actionSessionGet
    actionSessionDelete
    actionTokenCreate
    actionTokenRead

    MIDDLEWARE (endNotFound) ->
      endNotFound()
  ]
