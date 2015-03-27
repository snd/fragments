# the purpose of the **init** lifetime is to construct the **application** lifetime

module.exports.applicationLifetime = (
  ApplicationLifetime
) ->
  new ApplicationLifetime

module.exports.ApplicationLifetime = (
  applicationFactories
  requestFactories
  middlewareFactories
  tracingResolver
  forge
  namespaceResolver
  aliasResolver
) ->
  ApplicationLifetime = ->
    this.values =
      # self reference
      fragments_applicationLifetime: this

      # pass these values on from init lifetime to application lifetime
      # because we need them there as well
      fragments_applicationFactories: applicationFactories
      fragments_requestFactories: requestFactories
      fragments_middlewareFactories: middlewareFactories
      fragments_tracingResolver: tracingResolver
      fragments_namespaceResolver: namespaceResolver
      fragments_aliasResolver: aliasResolver
    return this
  ApplicationLifetime.prototype.factories = applicationFactories
  ApplicationLifetime.prototype.resolvers = [
    tracingResolver
    # auto resolves things like 'userTable'
    forge.newTableResolver()
    # auto resolves things like 'userTable' as `table.user`
    forge.newTableObjectResolver()
    # auto resolves things like 'firstUserWhereId'
    forge.newDataFirstResolver()
    # auto resolves things like 'selectUserWhereActive'
    forge.newDataSelectResolver()
    # auto resolves things like 'insertUser'
    forge.newDataInsertResolver()
    # auto resolves things like 'updateUserWhereId'
    forge.newDataUpdateResolver()
    # auto resolves things like 'deleteUserWhereId'
    forge.newDataDeleteResolver()
    namespaceResolver
    aliasResolver
    # auto resolves things like 'envIntPort'
    # this is after the alias resolver since it maps some things
    # to env vars
    forge.newEnvResolver()
  ]
  return ApplicationLifetime

################################################################################
# resolvers

module.exports.namesToTrace = ->
  []

module.exports.tracingResolver = (
  namesToTrace
  trace
) ->
  trace.newTracingResolver(namesToTrace)

module.exports.aliases = ->
  # fulfill config through env vars
  fragments_config_port: 'envIntPort'
  fragments_config_baseUrl: 'envStringBaseUrl'
  fragments_config_sessionSecret: 'envStringSessionSecret'
  fragments_config_jwtSigningSecret: 'envStringJwtSigningSecret'
  fragments_config_jwtEncryptionPassword: 'envStringJwtEncryptionPassword'
  fragments_config_redisSessionStorePrefix: 'envStringRedisSessionStorePrefix'
  fragments_config_redisUrl: 'envStringRedisUrl'
  fragments_config_redisDatabase: 'envIntRedisDatabase'
  fragments_config_migrationPath: 'envStringMigrationPath'
  fragments_config_databaseUrl: 'envStringDatabaseUrl'
  fragments_config_postgresDatabase: 'envStringPostgresDatabase'
  fragments_config_postgresPoolSize: 'envStringPostgresPoolSize'
  fragments_config_bcryptCost: 'envIntBcryptCost'
  fragments_config_staticPath: 'envStringStaticPath'

module.exports.aliasResolver = (
  forge
  aliases
) ->
  forge.newAliasResolver(aliases)

################################################################################
# require

module.exports.forge = ->
  require 'fragments-forge'

module.exports.trace = ->
  require 'hinoki-trace'
