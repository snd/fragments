COMMON_REQUEST_HEADERS = require '../common-request-headers'
COMMON_RESPONSE_HEADERS = require '../common-response-headers'

################################################################################
# get header by name

module.exports.fragments_getHeader = (
  fragments_req
) ->
  (name) ->
    fragments_req.headers[name.toLowerCase()] or null

################################################################################
# header{Identifier}:
# dependency that is the value of a specific header.
# example: headerCookie, headerAccept, headerReferer

for identifier, header of COMMON_REQUEST_HEADERS
  do (identifier, header) ->
    lowerCaseHeader = header.toLowerCase()
    module.exports["fragments_header#{identifier}"] = (fragments_req) ->
      fragments_req.headers[lowerCaseHeader] or null

################################################################################
# set header: setHeader[Identifier]
# dependency that is a function that sets the value of a specific header.
# example: setHeaderLocation(value), setHeaderETag(value)

module.exports.fragments_setHeader = (
  fragments_res
) ->
  (key, value) ->
    unless key? and value?
      throw new Error 'needs exactly two arguments'
    fragments_res.setHeader key, value

for identifier, header of COMMON_RESPONSE_HEADERS
  do (identifier, header) ->
    module.exports["fragments_setHeader#{identifier}"] = (fragments_res) ->
      (value) ->
        unless arguments.length is 1
          throw new Error 'needs exactly one argument'
        fragments_res.setHeader header, value

################################################################################
# set multiple headers at once

module.exports.fragments_setHeaders = (
  fragments_setHeader
) ->
  (headers) ->
    unless 'object' is typeof headers
      throw new Error 'needs one argument which must be an object'
    for own key, value of headers
      fragments_setHeader(key, value)

################################################################################
# quick way to set headers for common content types:
# setHeaderContentTypeHTML
# setHeaderContentTypeJSON
# setHeaderContentTypeXML
# setHeaderContentTypeText

QUICK_CONTENT_TYPES =
  HTML: 'text/html; charset=utf-8'
  JSON: 'application/json; charset=utf-8'
  XML: 'application/xml; charset=utf-8'
  Text: 'text/plain; charset=utf-8'

for identifier, contentType of QUICK_CONTENT_TYPES
  do (identifier, contentType) ->
    module.exports["fragments_setHeaderContentType#{identifier}"] = (
      fragments_setHeaderContentType
    ) ->
      ->
        fragments_setHeaderContentType contentType
