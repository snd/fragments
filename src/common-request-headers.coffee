# common request headers
# mostly taken from:
# http://en.wikipedia.org/wiki/List_of_HTTP_header_fields

module.exports =

  # standard

  Accept: 'accept'
  AcceptCharset: 'accept-charset'
  AcceptEncoding: 'accept-encoding'
  AcceptLanguage: 'accept-language'
  AcceptDatetime: 'accept-datetime'
  Authorization: 'authorization'
  CacheControl: 'cache-control'
  Connection: 'connection'
  Cookie: 'cookie'
  ContentLength: 'content-length'
  ContentMD5: 'content-md5'
  ContentType: 'content-type'
  Date: 'date'
  Expect: 'expect'
  From: 'from'
  Host: 'host'
  IfMatch: 'if-match'
  IfModifiedSince: 'if-modified-since'
  IfNoneMatch: 'if-none-match'
  IfRange: 'if-range'
  IfUnmodifiedSince: 'if-unmodified-since'
  MaxForwards: 'max-forwards'
  Origin: 'origin'
  Pragma: 'pragma'
  ProxyAuthorization: 'proxy-authorization'
  Range: 'range'
  Referer: 'referer'
  TE: 'te'
  UserAgent: 'user-agent'
  Upgrade: 'upgrade'
  Via: 'via'
  Warning: 'warning'

  # common non-standard

  XRequestedWith: 'x-requested-with'
  DNT: 'dnt'
  XForwardedFor: 'x-forwarded-for'
  XForwardedHost: 'x-forwarded-host'
  XForwardedProto: 'x-forwarded-proto'
  XHTTPMethodOverride: 'x-http-method-override'

  # other non-standard

  # country code provided by cloudflare geolocation
  CFIpcountry: 'cf-ipcountry'
