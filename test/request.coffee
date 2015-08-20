test = require 'tape'
got = require 'got'
streamToPromise = require 'stream-to-promise'
cookieModule = require 'cookie'

example = require '../example/app'

test 'hello world', (t) ->
  example (
    command_serve
    shutdown
    envStringBaseUrl
  ) ->
    command_serve('helloWorldServer')
      .then ->
        got envStringBaseUrl
      .then (res) ->
        t.equal res.statusCode, 200
        t.equal res.body, 'Hello World'
        shutdown()
      .then ->
        t.end()

test 'not found', (t) ->
  example (
    command_serve
    shutdown
    envStringBaseUrl
  ) ->
    command_serve()
      .then ->
        got envStringBaseUrl + '/not-found'
      .catch got.HTTPError, (err) ->
        t.equal err.statusCode, 404
        t.equal err.response.body, 'Not Found'
        shutdown()
      .then ->
        t.end()

test 'echo request data as json', (t) ->
  example (
    command_serve
    shutdown
    envStringBaseUrl
  ) ->
    command_serve()
      .then ->
        got.post envStringBaseUrl + '/echo?a=1&b=2',
          headers:
            'user-agent': 'integration t'
          json: true
          body:
            hello: 'world'
      .then (res) ->
        t.equal res.statusCode, 200
        planedBody =
          method: 'POST'
          url: '/echo?a=1&b=2'
          urlWithoutQuerystring: '/echo'
          query:
            a: '1'
            b: '2'
          body:
            hello: 'world'
          userAgent: 'integration t'
          ip: '::ffff:127.0.0.1'
          isGzipEnabled: true
          match:
            part: 'echo'
          alsoMatch: {}
          noMatch: null
          basicAuthCredentials: null
          session:
            cookie:
              path: '/'
              expires: null
              originalMaxAge: null
              httpOnly: true
          token: null
        t.deepEqual res.body, planedBody

        t.equal res.rawHeaders[0], 'X-Frame-Options'
        t.equal res.rawHeaders[1], 'sameorigin'
        t.equal res.rawHeaders[2], 'X-XSS-Protection'
        t.equal res.rawHeaders[3], '1; mode=block'
        t.equal res.rawHeaders[4], 'X-Content-Type-Options'
        t.equal res.rawHeaders[5], 'nosniff'
        t.equal res.rawHeaders[6], 'Strict-Transport-Security'
        t.equal res.rawHeaders[7], 'max-age=86400'
        t.equal res.rawHeaders[8], 'Vary'
        t.equal res.rawHeaders[9], 'accept-encoding'
        t.equal res.rawHeaders[10], 'Content-Type'
        t.equal res.rawHeaders[11], 'application/json; charset=utf-8'

        shutdown()
      .then ->
        t.end()

test 'method', (t) ->
  example (
    command_serve
    shutdown
    envStringBaseUrl
  ) ->
    command_serve()
      .then ->

        got envStringBaseUrl + '/method'
      .then (res) ->
        t.equal res.body, 'get'

        got.post envStringBaseUrl + '/method'
      .then (res) ->
        t.equal res.body, 'post'

        got.put envStringBaseUrl + '/method'
      .then (res) ->
        t.equal res.body, 'put'

        got.patch envStringBaseUrl + '/method'
      .then (res) ->
        t.equal res.body, 'patch'

        got.delete envStringBaseUrl + '/method'
      .then (res) ->
        t.equal res.body, 'delete'

        shutdown()
      .then ->
        t.end()

test 'any', (t) ->
  example (
    command_serve
    shutdown
    envStringBaseUrl
  ) ->
    command_serve()
      .then ->

        got envStringBaseUrl + '/any'
      .then (res) ->
        t.equal res.body, 'method is GET'

        got.post envStringBaseUrl + '/any'
      .then (res) ->
        t.equal res.body, 'method is POST'

        got.put envStringBaseUrl + '/any'
      .then (res) ->
        t.equal res.body, 'method is PUT'

        got.patch envStringBaseUrl + '/any'
      .then (res) ->
        t.equal res.body, 'method is PATCH'

        got.delete envStringBaseUrl + '/any'
      .then (res) ->
        t.equal res.body, 'method is DELETE'

        shutdown()
      .then ->
        t.end()

test 'error', (t) ->
  example (
    command_serve
    shutdown
    envStringBaseUrl
  ) ->
    command_serve()
      .then ->
        got envStringBaseUrl + '/error'
      .catch got.HTTPError, (err) ->
        t.equal err.statusCode, 500
        t.equal err.response.body, 'Server Error'
        shutdown()
      .then ->
        t.end()

test 'redirect', (t) ->
  example (
    command_serve
    shutdown
    envStringBaseUrl
  ) ->
    t.plan 3
    command_serve()
      .then ->
        stream = got.stream envStringBaseUrl + '/redirect'
        stream.on 'redirect', (res) ->
          t.equal res.statusCode, 302
          t.equal res.headers.location, '/redirect-target'
        streamToPromise(stream)
      .then (res) ->
        t.equal res.toString(), 'you made it'
        shutdown()
      .then ->
        t.end()

test 'text', (t) ->
  example (
    command_serve
    shutdown
    envStringBaseUrl
  ) ->
    command_serve()
      .then ->
        got envStringBaseUrl + '/text'
      .then (res) ->
        t.equal res.statusCode, 200
        t.equal res.body, 'Hello World'
        t.equal res.headers['content-type'], 'text/plain; charset=utf-8'
        shutdown()
      .then ->
        t.end()

test 'json', (t) ->
  example (
    command_serve
    shutdown
    envStringBaseUrl
  ) ->
    command_serve()
      .then ->

        got envStringBaseUrl + '/json'
      .catch got.HTTPError, (err) ->
        t.equal err.statusCode, 422
        t.equal err.response.body, '{"a":1}'
        t.equal err.response.headers['content-type'], 'application/json; charset=utf-8'
        shutdown()
      .then ->
        t.end()

test 'xml', (t) ->
  example (
    command_serve
    shutdown
    envStringBaseUrl
  ) ->
    command_serve()
      .then ->
        got envStringBaseUrl + '/xml'
      .catch got.HTTPError, (err) ->
        t.equal err.statusCode, 429
        t.equal err.response.body, '<test></test>'
        t.equal err.response.headers['content-type'], 'application/xml; charset=utf-8'
        shutdown()
      .then ->
        t.end()

test 'kup', (t) ->
  example (
    command_serve
    shutdown
    envStringBaseUrl
  ) ->
    command_serve()
      .then ->
        got envStringBaseUrl + '/kup'
      .then (res) ->
        t.equal res.statusCode, 200
        t.equal res.headers['content-type'], 'text/html; charset=utf-8'
        t.equal res.body, '<html><head><meta name="robots" content="index,follow" /><meta name="keywords" content="test" /></head><body><div id="container"><div id="navigation-wrapper"><div id="navigation"></div></div><div id="content-wrapper"><span>content</span></div></div></body></html>'
        shutdown()
      .then ->
        t.end()

test 'react', (t) ->
  example (
    command_serve
    shutdown
    envStringBaseUrl
  ) ->
    command_serve()
      .then ->
        got envStringBaseUrl + '/react'
      .then (res) ->
        t.equal res.statusCode, 200
        t.equal res.headers['content-type'], 'text/html; charset=utf-8'
        t.equal res.body, '<div id="content"></div>'
        shutdown()
      .then ->
        t.end()

test 'react kup', (t) ->
  example (
    command_serve
    shutdown
    envStringBaseUrl
  ) ->
    command_serve()
      .then ->
        got envStringBaseUrl + '/react-kup'
      .catch got.HTTPError, (err) ->
        t.equal err.statusCode, 404
        t.equal err.response.headers['content-type'], 'text/html; charset=utf-8'
        t.equal err.response.body, '<html><head></head><body><div id="container"><div id="navigation-wrapper"><div id="navigation"></div></div><div id="content-wrapper"><div id="content"></div></div></div></body></html>'
        shutdown()
      .then ->
        t.end()

test 'session', (t) ->
  example (
    command_serve
    shutdown
    envStringBaseUrl
    fragments_sessionCookieName
  ) ->
    command_serve()
      .bind({})
      .then ->
        got envStringBaseUrl + '/session',
          json: true
      .then (res) ->
        # session is initially empty except for the cookie
        delete res.body.cookie
        t.deepEqual res.body, {}

        cookieString = res.headers['set-cookie'][0]
        t.notEqual cookieString, null
        cookieObject = cookieModule.parse cookieString
        # session cookie was set
        sessionId = cookieObject[fragments_sessionCookieName]
        t.notEqual sessionId, null
        @cookie = cookieModule.serialize(fragments_sessionCookieName, sessionId)

        got.patch envStringBaseUrl + '/session',
          headers:
            cookie: @cookie
          json: true
          body:
            a: 1
      .then (res) ->
        delete res.body.cookie
        t.deepEqual res.body, {a: 1}

        got envStringBaseUrl + '/session',
          headers:
            cookie: @cookie
          json: true
      .then (res) ->
        delete res.body.cookie
        t.deepEqual res.body, {a: 1}

        got.patch envStringBaseUrl + '/session',
          headers:
            cookie: @cookie
          json: true
          body:
            a: 2
            b: 3
      .then (res) ->
        delete res.body.cookie
        t.deepEqual res.body, {a: 2, b: 3}

        got envStringBaseUrl + '/session',
          headers:
            cookie: @cookie
          json: true
      .then (res) ->
        delete res.body.cookie
        t.deepEqual res.body, {a: 2, b: 3}

        got.delete envStringBaseUrl + '/session',
          headers:
            cookie: @cookie
      .then (res) ->

        got envStringBaseUrl + '/session',
          headers:
            cookie: @cookie
          json: true
      .then (res) ->
        delete res.body.cookie
        t.deepEqual res.body, {}

        shutdown()
      .then ->
        t.end()

test 'token', (t) ->
  example (
    command_serve
    shutdown
    envStringBaseUrl
  ) ->
    command_serve()
      .bind({})
      .then ->
        got envStringBaseUrl + '/token',
          json: true
      .then (res) ->
        t.equal res.statusCode, 200
        t.equal res.body, null

        got.post envStringBaseUrl + '/token',
          json: true
          body:
            first_name: 'mad'
            last_name: 'max'
      .then (res) ->
        t.equal res.statusCode, 200
        t.ok res.body.token.length > 10
        this.token = res.body.token

        got envStringBaseUrl + '/token',
          json: true
          headers:
            authorization: "Bearer #{this.token}"
      .then (res) ->
        t.equal res.statusCode, 200
        t.deepEqual res.body,
          first_name: 'mad'
          last_name: 'max'

        got envStringBaseUrl + '/token',
          json: true
          headers:
            authorization: "Bearer garbagetoken"
      .then (res) ->
        t.equal res.statusCode, 200
        t.equal res.body, null

        got.post envStringBaseUrl + '/token',
          json: true
          body:
            first_name: 'bubba'
            last_name: 'zanetti'
      .then (res) ->
        t.equal res.statusCode, 200
        t.ok res.body.token.length > 10
        token = res.body.token

        got envStringBaseUrl + '/token',
          json: true
          headers:
            authorization: "Bearer #{token}"
      .then (res) ->
        t.equal res.statusCode, 200
        t.deepEqual res.body,
          first_name: 'bubba'
          last_name: 'zanetti'

        got envStringBaseUrl + '/token',
          json: true
          headers:
            authorization: "Bearer #{this.token}"
      .then (res) ->
        t.equal res.statusCode, 200
        t.deepEqual res.body,
          first_name: 'mad'
          last_name: 'max'

        shutdown()
      .then ->
        t.end()
