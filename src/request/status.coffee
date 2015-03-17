CAMELCASED_STATUS_CODES = require '../status-codes'

################################################################################
# setStatus[CodeOrIdentifier]
# dependency that is a function that sets a specific response status.
# example: setStatus404(), setStatusUnprocessable(), setStatusForbidden()

module.exports.fragments_setStatus = (
  fragments_res
) ->
  (value) ->
    fragments_res.statusCode = value

for statusCode, identifier of CAMELCASED_STATUS_CODES
  do (statusCode, identifier) ->
    factory = (
      fragments_setStatus
    ) ->
      ->
        fragments_setStatus statusCode
    module.exports["fragments_setStatus#{statusCode}"] = factory
    module.exports["fragments_setStatus#{identifier}"] = factory

################################################################################
# end[CodeOrIdentifier]
# dependency that is a function that ends request with a specific response status.
# example: end404(optionalContent), endNotFound(optionalContent),
# endForbidden(optionalContent), endOk(optionalContent)

for statusCode, camelcasedName of CAMELCASED_STATUS_CODES
  do (statusCode, camelcasedName) ->
    factory = (
      fragments_setStatus
      fragments_end
      fragments_http
    ) ->
      (data, args...) ->
        fragments_setStatus statusCode
        unless statusCode is 204 # no content
          # also send back some textual description of the status code
          # TODO maybe set content type to plaintext
          data ?= fragments_http.STATUS_CODES[statusCode]
        fragments_end data, args...
    # numeric status code
    module.exports["fragments_end#{statusCode}"] = factory
    # textual status code
    module.exports["fragments_end#{camelcasedName}"] = factory

################################################################################
# respond with status code and HTML, JSON, ...
# example: end404HTML(html), endNotFoundText(text), endUnprocessableJSON(object)
# and all other imaginable combinations...

[
  'HTML'
  'JSON'
  'XML'
  'Text'
  'React'
].forEach (content) ->
  for statusCode, camelcasedName of CAMELCASED_STATUS_CODES
    do (statusCode, camelcasedName) ->
      factory = (
        fragments_setStatus
        endX
      ) ->
        (args...) ->
          fragments_setStatus statusCode
          endX args...
      factory.$inject = ['fragments_setStatus', "fragments_end#{content}"]
      # numeric status code
      module.exports["fragments_end#{statusCode}#{content}"] = factory
      # textual status code
      module.exports["fragments_end#{camelcasedName}#{content}"] = factory
