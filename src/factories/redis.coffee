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

  if fragments_config_redisDatabase?
    redisClient.select fragments_config_redisDatabase

  fragments_onShutdown 'redis', ->
    fragments_console.log 'shutting down redis by calling redisClient.end()'
    new fragments_Promise (resolve, reject) ->
      redisClient.on 'end', ->
        fragments_console.log 'redis client has ended'
        resolve()
      redisClient.quit()

  return redisClient
