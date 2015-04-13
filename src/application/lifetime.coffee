# used to repeatedly get dependencies from this application lifetime
module.exports.fragments_APPLICATION = (
  fragments_applicationLifetime
  fragments_hinoki
) ->
  (factory) ->
    fragments_hinoki(
      fragments_applicationLifetime
      fragments_hinoki.getAndCacheNamesToInject(factory)
    ).spread(factory)
