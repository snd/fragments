got = require 'got'
streamToPromise = require 'stream-to-promise'
cookieModule = require 'cookie'

example = require '../example/app'

module.exports =

  'hello world': (test) ->
    example (
      command_serve
      shutdown
      envStringBaseUrl
    ) ->
      command_serve('helloWorldServer')
        .then ->
          got envStringBaseUrl
        .then (res) ->
          test.equal res.statusCode, 200
          test.equal res.body, 'Hello World'
          shutdown()
        .then ->
          test.done()

  'not found': (test) ->
    example (
      command_serve
      shutdown
      envStringBaseUrl
    ) ->
      command_serve()
        .then ->
          got envStringBaseUrl + '/not-found'
        .catch got.HTTPError, (err) ->
          test.equal err.statusCode, 404
          test.equal err.response.body, 'Not Found'
          shutdown()
        .then ->
          test.done()

  'echo request data as json': (test) ->
    example (
      command_serve
      shutdown
      envStringBaseUrl
    ) ->
      command_serve()
        .then ->
          got.post envStringBaseUrl + '/echo?a=1&b=2',
            headers:
              'user-agent': 'integration test'
            json: true
            body:
              hello: 'world'
        .then (res) ->
          test.equal res.statusCode, 200
          expectedBody =
            method: 'POST'
            url: '/echo?a=1&b=2'
            urlWithoutQuerystring: '/echo'
            query:
              a: '1'
              b: '2'
            body:
              hello: 'world'
            userAgent: 'integration test'
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
          test.deepEqual res.body, expectedBody

          test.equal res.rawHeaders[0], 'X-Frame-Options'
          test.equal res.rawHeaders[1], 'sameorigin'
          test.equal res.rawHeaders[2], 'X-XSS-Protection'
          test.equal res.rawHeaders[3], '1; mode=block'
          test.equal res.rawHeaders[4], 'X-Content-Type-Options'
          test.equal res.rawHeaders[5], 'nosniff'
          test.equal res.rawHeaders[6], 'Strict-Transport-Security'
          test.equal res.rawHeaders[7], 'max-age=86400'
          test.equal res.rawHeaders[8], 'Vary'
          test.equal res.rawHeaders[9], 'accept-encoding'
          test.equal res.rawHeaders[10], 'Content-Type'
          test.equal res.rawHeaders[11], 'application/json; charset=utf-8'

          shutdown()
        .then ->
          test.done()

  'method': (test) ->
    example (
      command_serve
      shutdown
      envStringBaseUrl
    ) ->
      command_serve()
        .then ->

          got envStringBaseUrl + '/method'
        .then (res) ->
          test.equal res.body, 'get'

          got.post envStringBaseUrl + '/method'
        .then (res) ->
          test.equal res.body, 'post'

          got.put envStringBaseUrl + '/method'
        .then (res) ->
          test.equal res.body, 'put'

          got.patch envStringBaseUrl + '/method'
        .then (res) ->
          test.equal res.body, 'patch'

          got.delete envStringBaseUrl + '/method'
        .then (res) ->
          test.equal res.body, 'delete'

          shutdown()
        .then ->
          test.done()

  'any': (test) ->
    example (
      command_serve
      shutdown
      envStringBaseUrl
    ) ->
      command_serve()
        .then ->

          got envStringBaseUrl + '/any'
        .then (res) ->
          test.equal res.body, 'method is GET'

          got.post envStringBaseUrl + '/any'
        .then (res) ->
          test.equal res.body, 'method is POST'

          got.put envStringBaseUrl + '/any'
        .then (res) ->
          test.equal res.body, 'method is PUT'

          got.patch envStringBaseUrl + '/any'
        .then (res) ->
          test.equal res.body, 'method is PATCH'

          got.delete envStringBaseUrl + '/any'
        .then (res) ->
          test.equal res.body, 'method is DELETE'

          shutdown()
        .then ->
          test.done()

  'error': (test) ->
    example (
      command_serve
      shutdown
      envStringBaseUrl
    ) ->
      command_serve()
        .then ->
          got envStringBaseUrl + '/error'
        .catch got.HTTPError, (err) ->
          test.equal err.statusCode, 500
          test.equal err.response.body, 'Server Error'
          shutdown()
        .then ->
          test.done()

  'redirect': (test) ->
    example (
      command_serve
      shutdown
      envStringBaseUrl
    ) ->
      test.expect 3
      command_serve()
        .then ->
          stream = got.stream envStringBaseUrl + '/redirect'
          stream.on 'redirect', (res) ->
            test.equal res.statusCode, 302
            test.equal res.headers.location, '/redirect-target'
          streamToPromise(stream)
        .then (res) ->
          test.equal res.toString(), 'you made it'
          shutdown()
        .then ->
          test.done()

  'text': (test) ->
    example (
      command_serve
      shutdown
      envStringBaseUrl
    ) ->
      command_serve()
        .then ->
          got envStringBaseUrl + '/text'
        .then (res) ->
          test.equal res.statusCode, 200
          test.equal res.body, 'Hello World'
          test.equal res.headers['content-type'], 'text/plain; charset=utf-8'
          shutdown()
        .then ->
          test.done()

  'json': (test) ->
    example (
      command_serve
      shutdown
      envStringBaseUrl
    ) ->
      command_serve()
        .then ->

          got envStringBaseUrl + '/json'
        .catch got.HTTPError, (err) ->
          test.equal err.statusCode, 422
          test.equal err.response.body, '{"a":1}'
          test.equal err.response.headers['content-type'], 'application/json; charset=utf-8'
          shutdown()
        .then ->
          test.done()

  'xml': (test) ->
    example (
      command_serve
      shutdown
      envStringBaseUrl
    ) ->
      command_serve()
        .then ->
          got envStringBaseUrl + '/xml'
        .catch got.HTTPError, (err) ->
          test.equal err.statusCode, 429
          test.equal err.response.body, '<test></test>'
          test.equal err.response.headers['content-type'], 'application/xml; charset=utf-8'
          shutdown()
        .then ->
          test.done()

  'kup': (test) ->
    example (
      command_serve
      shutdown
      envStringBaseUrl
    ) ->
      command_serve()
        .then ->
          got envStringBaseUrl + '/kup'
        .then (res) ->
          test.equal res.statusCode, 200
          test.equal res.headers['content-type'], 'text/html; charset=utf-8'
          test.equal res.body, '<html><head><meta name="robots" content="index,follow" /><meta name="keywords" content="test" /></head><body><div id="container"><div id="navigation-wrapper"><div id="navigation"></div></div><div id="content-wrapper"><span>content</span></div></div></body></html>'
          shutdown()
        .then ->
          test.done()

  'react': (test) ->
    example (
      command_serve
      shutdown
      envStringBaseUrl
    ) ->
      command_serve()
        .then ->
          got envStringBaseUrl + '/react'
        .then (res) ->
          test.equal res.statusCode, 200
          test.equal res.headers['content-type'], 'text/html; charset=utf-8'
          test.equal res.body, '<div id="content"></div>'
          shutdown()
        .then ->
          test.done()

  'react kup': (test) ->
    example (
      command_serve
      shutdown
      envStringBaseUrl
    ) ->
      command_serve()
        .then ->
          got envStringBaseUrl + '/react-kup'
        .catch got.HTTPError, (err) ->
          test.equal err.statusCode, 404
          test.equal err.response.headers['content-type'], 'text/html; charset=utf-8'
          test.equal err.response.body, '<html><head></head><body><div id="container"><div id="navigation-wrapper"><div id="navigation"></div></div><div id="content-wrapper"><div id="content"></div></div></div></body></html>'
          shutdown()
        .then ->
          test.done()

  'session': (test) ->
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
          test.deepEqual res.body, {}

          cookieString = res.headers['set-cookie'][0]
          test.notEqual cookieString, null
          cookieObject = cookieModule.parse cookieString
          # session cookie was set
          sessionId = cookieObject[fragments_sessionCookieName]
          test.notEqual sessionId, null
          @cookie = cookieModule.serialize(fragments_sessionCookieName, sessionId)

          got.patch envStringBaseUrl + '/session',
            headers:
              cookie: @cookie
            json: true
            body:
              a: 1
        .then (res) ->
          delete res.body.cookie
          test.deepEqual res.body, {a: 1}

          got envStringBaseUrl + '/session',
            headers:
              cookie: @cookie
            json: true
        .then (res) ->
          delete res.body.cookie
          test.deepEqual res.body, {a: 1}

          got.patch envStringBaseUrl + '/session',
            headers:
              cookie: @cookie
            json: true
            body:
              a: 2
              b: 3
        .then (res) ->
          delete res.body.cookie
          test.deepEqual res.body, {a: 2, b: 3}

          got envStringBaseUrl + '/session',
            headers:
              cookie: @cookie
            json: true
        .then (res) ->
          delete res.body.cookie
          test.deepEqual res.body, {a: 2, b: 3}

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
          test.deepEqual res.body, {}

          shutdown()
        .then ->
          test.done()

  'token': (test) ->
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
          test.equal res.statusCode, 200
          test.equal res.body, null

          got.post envStringBaseUrl + '/token',
            json: true
            body:
              first_name: 'mad'
              last_name: 'max'
        .then (res) ->
          test.equal res.statusCode, 200
          test.ok res.body.token.length > 10
          this.token = res.body.token

          got envStringBaseUrl + '/token',
            json: true
            headers:
              authorization: "Bearer #{this.token}"
        .then (res) ->
          test.equal res.statusCode, 200
          test.deepEqual res.body,
            first_name: 'mad'
            last_name: 'max'

          got envStringBaseUrl + '/token',
            json: true
            headers:
              authorization: "Bearer garbagetoken"
        .then (res) ->
          test.equal res.statusCode, 200
          test.equal res.body, null

          got.post envStringBaseUrl + '/token',
            json: true
            body:
              first_name: 'bubba'
              last_name: 'zanetti'
        .then (res) ->
          test.equal res.statusCode, 200
          test.ok res.body.token.length > 10
          token = res.body.token

          got envStringBaseUrl + '/token',
            json: true
            headers:
              authorization: "Bearer #{token}"
        .then (res) ->
          test.equal res.statusCode, 200
          test.deepEqual res.body,
            first_name: 'bubba'
            last_name: 'zanetti'

          got envStringBaseUrl + '/token',
            json: true
            headers:
              authorization: "Bearer #{this.token}"
        .then (res) ->
          test.equal res.statusCode, 200
          test.deepEqual res.body,
            first_name: 'mad'
            last_name: 'max'

          shutdown()
        .then ->
          test.done()
