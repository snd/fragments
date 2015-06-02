# used to repeatedly get dependencies from this application lifetime
module.exports.fragments_APPLICATION = (
  fragments_applicationLifetime
  fragments_hinoki
  fragments_source
) ->
  (factory) ->
    fragments_hinoki(
      fragments_source
      fragments_applicationLifetime
      factory
    )
