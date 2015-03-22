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

module.exports.fragments_sessionMiddleware = (
  fragments_expressSession
  fragments_config_sessionSecret
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
    cookie:
      httpOnly: true
