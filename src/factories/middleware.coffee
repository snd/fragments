################################################################################
# request time dependency injection system

# this is the most performance critical function in every app
# overwrite this if you need custom error handling
module.exports.fragments_MIDDLEWARE = (
  fragments_hinoki
  fragments_source
  fragments_applicationLifetime
) ->
  (factoryOrName) ->
    (req, res, next, params) ->
      # the first middleware that uses request time dependency injection
      # initializes request time dependency injection
      unless req.hinokiRequestLifetime?
        req.hinokiRequestLifetime =
          fragments_req: req
          fragments_res: res
      fragments_hinoki(
        fragments_source
        [
          fragments_applicationLifetime
          req.hinokiRequestLifetime
          {fragments_next: next, fragments_params: params}
        ]
        factoryOrName
      ).catch (err) ->
        # your custom error handling
        console.log 'ERROR'
        console.log err
        console.log err.stack
        res.statusCode = 500
        res.end 'Server Error'

################################################################################
# for routing: makes a route middleware from a factory

[
  'get'
  'post'
  'put'
  'delete'
  'patch'
  'any'
].forEach (method) ->
  module.exports["fragments_#{method.toUpperCase()}"] = (
    fragments_passage
    fragments_MIDDLEWARE
  ) ->
    (urlPattern, factoryOrName) ->
      fragments_passage[method] urlPattern, fragments_MIDDLEWARE factoryOrName
