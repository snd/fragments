# common response headers
# mostly taken from:
# http://en.wikipedia.org/wiki/List_of_HTTP_header_fields

module.exports =

  # standard

  AccessControlAllowOrigin: 'access-control-allow-origin'
  AcceptPatch: 'accept-patch'
  AcceptRanges: 'accept-ranges'
  Age: 'age'
  Allow: 'allow'
  CacheControl: 'cache-control'
  Connection: 'connection'
  ContentEncoding: 'content-encoding'
  ContentLanguage: 'content-language'
  ContentLength: 'content-length'
  ContentLocation: 'content-location'
  ContentMD5: 'content-md5'
  ContentDisposition: 'content-disposition'
  ContentRange: 'content-range'
  ContentType: 'content-type'
  Date: 'date'
  ETag: 'etag'
  Expires: 'expires'
  LastModified: 'last-modified'
  Link: 'link'
  Location: 'location'
  P3P: 'p3p'
  Pragma: 'pragma'
  ProxyAuthenticate: 'proxy-authenticate'
  Refresh: 'refresh'
  RetryAfter: 'retry-after'
  Server: 'server'
  SetCookie: 'set-cookie'
  Status: 'status'
  StrictTransportSecurity: 'strict-transport-security'
  Trailer: 'trailer'
  TransferEncoding: 'transfer-encoding'
  Upgrade: 'upgrade'
  Vary: 'vary'
  Via: 'via'
  Warning: 'warning'
  WWWAuthenticate: 'www-authenticate'
  XFrameOptions: 'x-frame-options'

  # common non-standard

  XXXSProtection: 'x-xss-protection'
  ContentSecurityPolicy: 'content-security-policy'
  XContentTypeOptions: 'x-content-type-options'
