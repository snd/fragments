# common response headers
# mostly taken from:
# http://en.wikipedia.org/wiki/List_of_HTTP_header_fields

module.exports =

  # standard

  AccessControlAllowOrigin: 'Access-Control-Allow-Origin'
  AcceptPatch: 'Accept-Patch'
  AcceptRanges: 'Accept-Ranges'
  Age: 'Age'
  Allow: 'Allow'
  CacheControl: 'Cache-Control'
  Connection: 'Connection'
  ContentEncoding: 'Content-Encoding'
  ContentLanguage: 'Content-Language'
  ContentLength: 'Content-Length'
  ContentLocation: 'Content-Location'
  ContentMD5: 'Content-MD5'
  ContentDisposition: 'Content-Disposition'
  ContentRange: 'Content-Range'
  ContentType: 'Content-Type'
  Date: 'Date'
  ETag: 'ETag'
  Expires: 'Expires'
  LastModified: 'Last-Modified'
  Link: 'Link'
  Location: 'Location'
  P3P: 'P3P'
  Pragma: 'Pragma'
  ProxyAuthenticate: 'Proxy-Authenticate'
  Refresh: 'Refresh'
  RetryAfter: 'Retry-After'
  Server: 'Server'
  SetCookie: 'Set-Cookie'
  Status: 'Status'
  StrictTransportSecurity: 'Strict-Transport-Security'
  Trailer: 'Trailer'
  TransferEncoding: 'Transfer-Encoding'
  Upgrade: 'Upgrade'
  Vary: 'Vary'
  Via: 'Via'
  Warning: 'Warning'
  WWWAuthenticate: 'WWW-Authenticate'
  XFrameOptions: 'X-Frame-Options'

  # common non-standard

  XXXSProtection: 'X-XSS-Protection'
  ContentSecurityPolicy: 'Content-Security-Policy'
  XContentTypeOptions: 'X-Content-Type-Options'
