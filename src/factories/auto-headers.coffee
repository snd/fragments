# EXPERIMENTAL

# currently only security headers taken from:
# https://www.owasp.org/index.php/List_of_useful_HTTP_headers
#
# read also:
# http://ibuildings.nl/blog/2013/03/4-http-security-headers-you-should-always-be-using
module.exports.fragments_autoHeaders = ->
  secondsInADay = 24 * 60 * 60
  secondsInAYear = 365 * secondsInADay
  {
    # force that the page can only be displayed in a frame
    # (<frame>, <iframe>, <object) on the same origin as the page itself.
    # used to prevent clickjacking.
    # https://developer.mozilla.org/en-US/docs/Web/HTTP/X-Frame-Options
    'X-Frame-Options': 'sameorigin'

    # enable the cross-site scripting filter built into IE8+ and chrome
    # even if the user disabled it.
    # `mode=block` will prevent rendering completely instead of just sanitizing
    'X-XSS-Protection': '1; mode=block'

    # prevents internet explorer and google chrome from
    # mime-sniffing a response away from the declared content-type.
    # this reduces exposure to drive-by download attacks.
    'X-Content-Type-Options': 'nosniff'

    # once a supported browser receives this header that browser will
    # prevent any communications from being sent over http to the
    # specified domain and will instead send all communications over https.
    # the strict-transport-security header is ignored by the browser
    # when your site is accessed using http; this is because an attacker
    # may intercept http connections and inject the header or remove it.
    # read also:
    # https://www.owasp.org/index.php/HTTP_Strict_Transport_Security
    'Strict-Transport-Security': "max-age=#{secondsInADay}"

    # since we are using compression its important that
    # caches cache different versions for different encodings.
    # read also:
    # http://www.fastly.com/blog/best-practices-for-using-the-vary-header/
    'Vary': 'accept-encoding'
  }

module.exports.fragments_autoHeadersMiddleware = (
  fragments_MIDDLEWARE
) ->
  fragments_MIDDLEWARE (
    fragments_setHeaders
    fragments_autoHeaders
    fragments_next
  ) ->
    fragments_setHeaders fragments_autoHeaders
    fragments_next()
