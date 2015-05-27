module.exports.fragments_shutdownState = (
  fragments_zuvor
) ->
  {
    isShutdown: false
    callbacks: {}
    order: new fragments_zuvor.Graph()
  }

module.exports.fragments_isShutdown = (
  fragments_shutdownState
) ->
  ->
    fragments_shutdownState.isShutdown

# module.exports.fragments_resetShutdownState = (
#   fragments_shutdownState
#   fragments_zuvor
# ) ->
#   ->
#     fragments_shutdownState.callbacks = {}
#     fragments_shutdownState.isCalled = false
#     fragments_shutdownState.order = new fragments_zuvor.Graph()
#     return fragments_shutdownState

module.exports.fragments_onShutdown = (
  fragments_shutdownState
) ->
  (key, cb) ->
    unless 'function' is typeof cb
      throw new Error 'cb argument must be a function'
    if fragments_shutdownState.callbacks[key]?
      throw new Error "shutdown callback already registered for key `#{key}`"
    fragments_shutdownState.callbacks[key] = cb

module.exports.fragments_shutdownBefore = (
  fragments_shutdownState
) ->
  (before, after) ->
    fragments_shutdownState.order.add(before, after)

module.exports.fragments_shutdown = (
  fragments_Promise
  fragments_shutdownState
  fragments_isShutdown
  fragments_console
  fragments_zuvor
) ->
  ->
    # ensure that shutdown is only called once
    if fragments_isShutdown()
      throw new Error 'shutdown can only be called once per application lifetime'
    fragments_shutdownState.isShutdown = true

    fragments_console.log 'shutting down'

    fragments_console.log 'shutdown callbacks:'
    fragments_console.log Object.keys fragments_shutdownState.callbacks

    fragments_console.log 'shutdown order:'
    fragments_console.log fragments_shutdownState.order.edges()

    fragments_zuvor.run(
      ids: Object.keys fragments_shutdownState.callbacks
      graph: fragments_shutdownState.order
      callback: (id) ->
        callback = fragments_shutdownState.callbacks[id]
        if callback?
          fragments_console.log "calling shutdown callback `#{id}`"
          callback()
        else
          fragments_console.log "no shutdown callback for `#{id}` - ignoring"
          fragments_Promise.resolve()
    ).then ->
      fragments_console.log 'shutdown complete'
