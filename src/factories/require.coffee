################################################################################
# node module requires

module.exports.fragments_http = ->
  require 'http'

module.exports.fragments_net = ->
  require 'net'

module.exports.fragments_fs = (fragments_Promise) ->
  fragments_Promise.promisifyAll require 'fs'

module.exports.fragments_path = ->
  require 'path'

module.exports.fragments_url = ->
  require 'url'

module.exports.fragments_crypto = ->
  require 'crypto'

module.exports.fragments_querystring = ->
  require 'querystring'

module.exports.fragments_childProcess = (fragments_Promise) ->
  fragments_Promise.promisifyAll require 'child_process'

################################################################################
# snd npm module requires

module.exports.fragments_sequenz = ->
  require 'sequenz'

module.exports.fragments_zuvor = ->
  require 'zuvor'

module.exports.fragments_UrlPattern = ->
  require 'url-pattern'

module.exports.fragments_passage = ->
  require 'passage'

module.exports.fragments_kup = (
  fragments_reactToHtml
) ->
  K = require 'kup'
  K.prototype.react = (args...) ->
    this.unsafe fragments_reactToHtml args...
  return K

module.exports.fragments_hinoki = ->
  require 'hinoki'

module.exports.fragments_helfer = ->
  require 'helfer'

################################################################################
# npm module requires

module.exports.fragments_Promise = ->
  require 'bluebird'

module.exports.fragments_lodash = ->
  require 'lodash'

module.exports.fragments__ = ->
  require 'lodash'

module.exports.fragments_redis = ->
  require 'redis'

module.exports.fragments_bcrypt = (fragments_Promise) ->
  fragments_Promise.promisifyAll require 'bcrypt'

module.exports.fragments_uuid = ->
  require 'node-uuid'

module.exports.fragments_react = ->
  react = require 'react/addons'
  react.kup = require('react-kup')
  react

module.exports.fragments_jwt = ->
  require 'jsonwebtoken'

module.exports.fragments_isjs = ->
  require 'is_js'

################################################################################
# express middleware requires

module.exports.fragments_connect = ->
  require 'connect'

module.exports.fragments_connectRedis = ->
  require 'connect-redis'

module.exports.fragments_expressCompression = ->
  require 'compression'

module.exports.fragments_expressServeStatic = ->
  require 'serve-static'

module.exports.fragments_expressBodyParser = ->
  require 'body-parser'

module.exports.fragments_queryParser = (fragments_url) ->
  qs = require 'query-string'

  (options) ->
    (req, res, next) ->
      if req.query?
        next()
        return

      if req.url.indexOf('?') is -1
        req.query = {}
      else
        parsedUrl = fragments_url.parse req.url
        req.query = qs.parse(parsedUrl.query, options)

      next()

module.exports.fragments_expressCookieParser = ->
  require 'cookie-parser'

module.exports.fragments_expressSession = ->
  require 'express-session'

module.exports.fragments_basicAuth = ->
  require 'basic-auth'

module.exports.fragments_expressJwt = ->
  require 'express-jwt'
