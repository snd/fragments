module.exports.fragments_method = (fragments_req) ->
  fragments_req.method

module.exports.fragments_url = (fragments_req) ->
  fragments_req.url

module.exports.fragments_urlWithoutQuerystring = (fragments_req) ->
  fragments_req.url.split('?')[0]

module.exports.fragments_query = (fragments_req) ->
  fragments_req.query

module.exports.fragments_body = (fragments_req) ->
  fragments_req.body

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

module.exports.fragments_sessionID = (fragments_req) ->
   fragments_req.sessionID

module.exports.fragments_userAgent = (fragments_headerUserAgent) ->
   fragments_headerUserAgent

module.exports.fragments_ip = (
  fragments_headerXForwardedFor
  fragments_req
) ->
  # From Jacob, Heroku's Director of Security:
  # "The router doesn't overwrite X-Forwarded-For,
  # but it does guarantee that the real origin will
  # always be the last item in the list."
  # source: http://stackoverflow.com/a/18517550
  # ips are safe from spoofing on heroku
  # in other hosting environments ymmv.
  if fragments_headerXForwardedFor?
    forwardedForItems = fragments_headerXForwardedFor.split ','
    lastItem = forwardedForItems[forwardedForItems.length - 1]
    lastItem.trim()
  else
    fragments_req.connection.remoteAddress

################################################################################
# request accessors

module.exports.fragments_isGzipEnabled = (
  fragments_headerAcceptEncoding
) ->
  ->
    acceptEncoding = fragments_headerAcceptEncoding
    acceptEncoding? and -1 isnt acceptEncoding.indexOf('gzip')

module.exports.fragments_matchCurrentUrl = (
  fragments_urlWithoutQuerystring
  fragments_urlPattern
) ->
  (pattern) ->
    patternObject = fragments_urlPattern.newPattern pattern
    patternObject.match fragments_urlWithoutQuerystring
