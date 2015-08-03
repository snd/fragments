module.exports.fragments_RedisSessionStore = (
  fragments_expressSession
  fragments_connectRedis
) ->
  fragments_connectRedis fragments_expressSession

module.exports.fragments_redisSessionStore = (
  fragments_RedisSessionStore
  fragments_redisClient
  fragments_config_redisSessionStorePrefix
) ->
  new fragments_RedisSessionStore
    client: fragments_redisClient
    prefix: fragments_config_redisSessionStorePrefix

module.exports.fragments_sessionCookieName = ->
  # dont make it so easy to find out we are using connect
  'session-id'

module.exports.fragments_sessionMiddleware = (
  fragments_expressSession
  fragments_config_sessionSecret
  fragments_sessionCookieName
  fragments_redisSessionStore
  fragments_uuid
) ->
  fragments_expressSession
    secret: fragments_config_sessionSecret
    store: fragments_redisSessionStore
    # use uuids for session ids
    genid: -> fragments_uuid.v4()
    # make warnings disappear
    saveUninitialized: true
    resave: false
    name: fragments_sessionCookieName
    cookie:
      httpOnly: true

module.exports.fragments_session = (
  fragments_sessionMiddleware
  fragments_req
  fragments_res
  fragments_Promise
) ->
  # req has already been passed through sessionMiddleware and req.session
  # has been added.
  # either because sessionMiddleware is in the middleware chain or
  # on demand (see below).
  if fragments_req.session?
    return fragments_req.session
  # req has not been through sessionMiddleware.
  # do it now.
  # by doing it on demand we save one redis request on routes that dont
  # use the session.
  # this happens at most once per request.
  new fragments_Promise (resolve, reject) ->
    fragments_sessionMiddleware fragments_req, fragments_res, (err) ->
      if err?
        return reject err
      resolve fragments_req.session

module.exports.fragments_sessionID = (
  fragments_req
  # force req to be passed through fragments_sessionMiddleware which
  # sets res.sessionID
  fragments_session
) ->
  fragments_req.sessionID
