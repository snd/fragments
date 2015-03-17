################################################################################
# redis

module.exports.fragments_redisClient = (
  fragments_Promise
  fragments_url
  fragments_redis
  fragments_console
  fragments_config_redisUrl
  fragments_config_redisDatabase
  fragments_onShutdown
) ->
  parsedRedisURL = fragments_url.parse fragments_config_redisUrl
  redisPort= parsedRedisURL.port
  redisHost = parsedRedisURL.hostname

  if parsedRedisURL.auth?
    redisPassword = parsedRedisURL.auth.split(':')[1]

  redisClient = fragments_redis.createClient redisPort, redisHost
  redisClient.auth redisPassword if redisPassword?

  redisClient.select fragments_config_redisDatabase

  fragments_onShutdown 'redis', ->
    fragments_console.log 'shutting down redis by calling redisClient.end()'
    new fragments_Promise (resolve, reject) ->
      redisClient.on 'end', ->
        fragments_console.log 'redis client has ended'
        resolve()
      redisClient.quit()

  return redisClient

module.exports.fragments_RedisStore = (
  fragments_expressSession
  fragments_connectRedis
) ->
  fragments_connectRedis fragments_expressSession

module.exports.fragments_redisSessionStore = (
  fragments_RedisStore
  fragments_redisClient
  fragments_config_redisSessionStorePrefix
) ->
  new fragments_RedisStore
    client: fragments_redisClient
    prefix: fragments_config_redisSessionStorePrefix

################################################################################
# session

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
