################################################################################
# request time dependency injection system

module.exports.fragments_RequestLifetime = (
  fragments_requestFactories
  fragments_tracingResolver
  fragments_namespaceResolver
  fragments_aliasResolver
) ->
  RequestLifetime = (req, res) ->
    this.values =
      fragments_req: req
      fragments_res: res
    return this

  RequestLifetime.prototype.factories = fragments_requestFactories
  RequestLifetime.prototype.resolvers = [
    # tracingResolver
    fragments_namespaceResolver
    fragments_aliasResolver
  ]
  return RequestLifetime

module.exports.fragments_MiddlewareLifetime = (
  fragments_middlewareFactories
  fragments_tracingResolver
  fragments_namespaceResolver
  fragments_aliasResolver
) ->
  MiddlewareLifetime = (next, params) ->
    this.values =
      fragments_params: params
      fragments_next: next
    return this

  MiddlewareLifetime.prototype.factories = fragments_middlewareFactories
  MiddlewareLifetime.prototype.resolvers = [
    # tracingResolver
    fragments_namespaceResolver
    fragments_aliasResolver
  ]
  return MiddlewareLifetime

# this is the most performance critical function in every app
# overwrite this if you need custom error handling
module.exports.fragments_MIDDLEWARE = (
  fragments_hinoki
  fragments_applicationLifetime
  fragments_RequestLifetime
  fragments_MiddlewareLifetime
) ->
  (middlewareFactory) ->
    (req, res, next, params) ->
      # the first middleware that uses request time dependency injection
      # initializes request time dependency injection
      unless req.hinokiRequestLifetime?
        req.hinokiRequestLifetime = new fragments_RequestLifetime req, res
      fragments_hinoki.get(
        [
          new fragments_MiddlewareLifetime(next, params)
          req.hinokiRequestLifetime
          fragments_applicationLifetime
        ]
        fragments_hinoki.getAndCacheNamesToInject(middlewareFactory)
      )
        .spread(middlewareFactory)
        # your custom error handling
        .catch (err) ->
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
    (urlPattern, routeFactory) ->
      routeMiddleware = fragments_MIDDLEWARE routeFactory
      fragments_passage[method](urlPattern, routeMiddleware)
