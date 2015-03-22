Promise = require 'bluebird'
request = require 'request'
requestPromise = Promise.promisify(request)

example = require '../../example/app'

module.exports =

  'hello world': (test) ->
    example (
      command_serve
      shutdown
      envStringBaseUrl
    ) ->
      command_serve('helloWorldServer')
        .then ->
          requestPromise(
            method: 'GET'
            url: envStringBaseUrl
          )
        .then ([response]) ->
          test.equal response.statusCode, 200
          test.equal response.body, 'Hello World'
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
          requestPromise(
            method: 'GET'
            url: envStringBaseUrl + '/not-found'
          )
        .then ([response]) ->
          test.equal response.statusCode, 404
          test.equal response.body, 'Not Found'
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
          requestPromise(
            method: 'GET'
            url: envStringBaseUrl + '/echo?a=1&b=2'
            json: true
            headers:
              'user-agent': 'integration test'
            body:
              hello: 'world'
          )
        .then ([response]) ->
          test.equal response.statusCode, 200
          test.deepEqual response.body,
            method: 'GET'
            url: '/echo?a=1&b=2'
            urlWithoutQuerystring: '/echo'
            query:
              a: '1'
              b: '2'
            body:
              hello: 'world'
            userAgent: 'integration test'
            ip: '::ffff:127.0.0.1'
            isGzipEnabled: false
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

          requestPromise(
            method: 'GET'
            url: envStringBaseUrl + '/method'
          )
        .then ([response]) ->
          test.equal response.body, 'get'

          requestPromise(
            method: 'POST'
            url: envStringBaseUrl + '/method'
          )
        .then ([response]) ->
          test.equal response.body, 'post'

          requestPromise(
            method: 'PUT'
            url: envStringBaseUrl + '/method'
          )
        .then ([response]) ->
          test.equal response.body, 'put'

          requestPromise(
            method: 'PATCH'
            url: envStringBaseUrl + '/method'
          )
        .then ([response]) ->
          test.equal response.body, 'patch'

          requestPromise(
            method: 'DELETE'
            url: envStringBaseUrl + '/method'
          )
        .then ([response]) ->
          test.equal response.body, 'delete'

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

          requestPromise(
            method: 'GET'
            url: envStringBaseUrl + '/any'
          )
        .then ([response]) ->
          test.equal response.body, 'method is GET'

          requestPromise(
            method: 'POST'
            url: envStringBaseUrl + '/any'
          )
        .then ([response]) ->
          test.equal response.body, 'method is POST'

          requestPromise(
            method: 'PUT'
            url: envStringBaseUrl + '/any'
          )
        .then ([response]) ->
          test.equal response.body, 'method is PUT'

          requestPromise(
            method: 'PATCH'
            url: envStringBaseUrl + '/any'
          )
        .then ([response]) ->
          test.equal response.body, 'method is PATCH'

          requestPromise(
            method: 'DELETE'
            url: envStringBaseUrl + '/any'
          )
        .then ([response]) ->
          test.equal response.body, 'method is DELETE'

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
          requestPromise(
            method: 'GET'
            url: envStringBaseUrl + '/error'
          )
        .then ([response]) ->
          test.equal response.statusCode, 500
          test.equal response.body, 'Server Error'
          shutdown()
        .then ->
          test.done()

  'redirect': (test) ->
    example (
      command_serve
      shutdown
      envStringBaseUrl
    ) ->
      command_serve()
        .then ->
          requestPromise(
            method: 'GET'
            url: envStringBaseUrl + '/redirect'
            followRedirect: false
          )
        .then ([response]) ->
          test.equal response.statusCode, 302
          test.equal response.headers.location, '/go-here'
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
          requestPromise(
            method: 'GET'
            url: envStringBaseUrl + '/text'
          )
        .then ([response]) ->
          test.equal response.statusCode, 200
          test.equal response.body, 'Hello World'
          test.equal response.headers['content-type'], 'text/plain; charset=utf-8'
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
          requestPromise(
            method: 'GET'
            url: envStringBaseUrl + '/json'
          )
        .then ([response]) ->
          test.equal response.statusCode, 422
          test.equal response.body, '{"a":1}'
          test.equal response.headers['content-type'], 'application/json; charset=utf-8'
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
          requestPromise(
            method: 'GET'
            url: envStringBaseUrl + '/xml'
          )
        .then ([response]) ->
          test.equal response.statusCode, 429
          test.equal response.body, '<test></test>'
          test.equal response.headers['content-type'], 'application/xml; charset=utf-8'
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
          requestPromise(
            method: 'GET'
            url: envStringBaseUrl + '/kup'
          )
        .then ([response]) ->
          test.equal response.statusCode, 200
          test.equal response.headers['content-type'], 'text/html; charset=utf-8'
          test.equal response.body, '<html><head><meta name="robots" content="index,follow" /><meta name="keywords" content="test" /></head><body><div id="container"><div id="navigation-wrapper"><div id="navigation"></div></div><div id="content-wrapper"><span>content</span></div></div></body></html>'
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
          requestPromise(
            method: 'GET'
            url: envStringBaseUrl + '/react'
          )
        .then ([response]) ->
          test.equal response.statusCode, 200
          test.equal response.headers['content-type'], 'text/html; charset=utf-8'
          test.equal response.body, '<div id="content"></div>'
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
          requestPromise(
            method: 'GET'
            url: envStringBaseUrl + '/react-kup'
          )
        .then ([response]) ->
          test.equal response.statusCode, 404
          test.equal response.headers['content-type'], 'text/html; charset=utf-8'
          test.equal response.body, '<html><head></head><body><div id="container"><div id="navigation-wrapper"><div id="navigation"></div></div><div id="content-wrapper"><div id="content"></div></div></div></body></html>'
          shutdown()
        .then ->
          test.done()
