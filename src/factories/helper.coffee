# TODO move these to fragment-user

################################################################################
# open port finder
# source: https://gist.github.com/mikeal/1840641

module.exports.fragments_getOpenPort = (
  fragments_Promise
  fragments_net
) ->
  getOpenPort = (port = 8000, tries = 100) ->
    if tries < 1
      return fragments_Promise.reject new Error "tries exhausted at port #{port}"
    new fragments_Promise (resolve) ->
      server = fragments_net.createServer()
      server.once 'listening', ->
        server.once 'close', ->
          resolve port
        server.close()
      server.once 'error', ->
        resolve getOpenPort (port + 1), (tries - 1)
      server.listen port

  return getOpenPort

################################################################################
# password

module.exports.fragments_comparePasswordToHashed = (
  fragments_bcrypt
) ->
  (password, hash) ->
    fragments_bcrypt.compareAsync password, hash

module.exports.fragments_hashPassword = (
  fragments_Promise
  fragments_bcrypt
  fragments_config_bcryptCost
) ->
  (password) ->
    if password?
      fragments_bcrypt.genSaltAsync(fragments_config_bcryptCost).then (salt) ->
        fragments_bcrypt.hashAsync password, salt
    else
      fragments_Promise.resolve null

################################################################################
# record helpers

module.exports.fragments_setCreatedAt = (
  fragments_lodash
) ->
  (record) ->
    defensiveCopy = fragments_lodash.clone record
    defensiveCopy.created_at = new Date
    defensiveCopy

module.exports.fragments_setUpdatedAt = (
  fragments_lodash
) ->
  (record) ->
      defensiveCopy = fragments_lodash.clone record
      defensiveCopy.updated_at = new Date
      defensiveCopy

module.exports.fragments_hashPasswordIfPresent = (
  fragments_Promise
  fragments_lodash
  fragments_hashPassword
) ->
  (record, key = 'password') ->
    if record[key]?
      fragments_hashPassword(record[key]).then (hashedPassword) ->
        defensiveCopy = fragments_lodash.clone record
        defensiveCopy[key] = hashedPassword
        defensiveCopy
    else
      fragments_Promise.resolve record
