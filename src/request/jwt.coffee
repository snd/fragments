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
