module.exports.fragments_jwtRequestProperty = ->
  'token'

module.exports.fragments_jwtMiddleware = (
  fragments_expressJwt
  fragments_jwtRequestProperty
  fragments_config_jwtSigningSecret
) ->
  fragments_expressJwt
    secret: fragments_config_jwtSigningSecret
    requestProperty: fragments_jwtRequestProperty
    # audience:
    # issuer:

module.exports.fragments_newJwt = (
  fragments_jwt
  fragments_encryptAesSha256
  fragments_config_jwtEncryptionPassword
  fragments_config_jwtSigningSecret
) ->
  (payload) ->
    # encrypt to make token unreadable in transfer without a password
    encryptedPayload = fragments_encryptAesSha256(
      fragments_config_jwtEncryptionPassword
      JSON.stringify(payload)
    )

    # sign to detect (prevent) tampering with the token
    fragments_jwt.sign(
      encryptedPayload
      fragments_config_jwtSigningSecret
      {expirationInMinutes: 60}
    )

module.exports.fragments_decryptJwt = (
  fragments_decryptAesSha256
  fragments_config_jwtEncryptionPassword
) ->
  (encrypted) ->
    fragments_decryptAesSha256(fragments_config_jwtEncryptionPassword, encrypted)

module.exports.fragments_token = (
  fragments_expressJwt
  fragments_req
  fragments_res
  fragments_jwtMiddleware
  fragments_jwtRequestProperty
  fragments_decryptJwt
  fragments_Promise
) ->
  if fragments_req[fragments_jwtRequestProperty]?
    return JSON.parse fragments_decryptJwt fragments_req[fragments_jwtRequestProperty]

  new fragments_Promise (resolve, reject) ->
    fragments_jwtMiddleware fragments_req, fragments_res, ->
      if err?
        return reject err
      if fragments_req[fragments_jwtRequestProperty]?
        resolve JSON.parse fragments_decryptJwt fragments_req[fragments_jwtRequestProperty]
      else
        resolve null
