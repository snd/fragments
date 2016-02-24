module.exports.fragments_config_port = (envIntPort) ->
  envIntPort

module.exports.fragments_config_baseUrl = (envStringBaseUrl) ->
  envStringBaseUrl

module.exports.fragments_config_staticPath = (envStringStaticPath) ->
  envStringStaticPath

module.exports.fragments_config_jwtSigningSecret = (envStringJwtSigningSecret) ->
  envStringJwtSigningSecret

module.exports.fragments_config_jwtEncryptionPassword = (envStringJwtEncryptionPassword) ->
  envStringJwtEncryptionPassword

module.exports.fragments_config_redisUrl = (envStringRedisUrl) ->
  envStringRedisUrl

module.exports.fragments_config_redisDatabase = (maybeEnvIntRedisDatabase) ->
  maybeEnvIntRedisDatabase

module.exports.fragments_config_redisPrefix = (envStringRedisPrefix) ->
  envStringRedisPrefix

module.exports.fragments_config_sessionSecret = (envStringSessionSecret) ->
  envStringSessionSecret

module.exports.fragments_config_bcryptCost = (envIntBcryptCost) ->
  envIntBcryptCost
