module.exports.fragments_session = (
  fragments_sessionMiddleware
  fragments_req
  fragments_res
  fragments_Promise
) ->
  # req has already been passed through sessionMiddleware and req.session
  # has been added.
  # either because sessionMiddleware is in the middleware chain or
  # on demand (see below).
  if fragments_req.session?
    fragments_req.session
  # req has not been through sessionMiddleware.
  # do it now.
  # by doing it on demand we save one redis request on routes that dont
  # use the session.
  # this happens at most once per request.
  else
    new fragments_Promise (resolve, reject) ->
      fragments_sessionMiddleware fragments_req, fragments_res, (err) ->
        if err?
          return reject err
        resolve fragments_req.session

module.exports.fragments_sessionID = (
  fragments_req
  # force req to be passed through fragments_sessionMiddleware which
  # sets res.sessionID
  fragments_session
) ->
  fragments_req.sessionID
