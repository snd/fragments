# TODO document this
module.exports.fragments_encryptionAlgorithm = ->
  'aes-256-cbc'

# see: https://auth0.com/blog/2014/01/27/ten-things-you-should-know-about-tokens-and-cookies/#confidential-info
module.exports.fragments_encryptAesSha256 = (
  fragments_crypto
  fragments_encryptionAlgorithm
) ->

  (password, textToEncrypt) ->
    cipher = fragments_crypto.createCipher(
      fragments_encryptionAlgorithm
      password
    )
    encrypted = cipher.update(textToEncrypt, 'utf8', 'hex')
    encrypted += cipher.final('hex')
    return encrypted

module.exports.fragments_decryptAesSha256 = (
  fragments_crypto
  fragments_encryptionAlgorithm
) ->

  (password, textToDecrypt) ->
    decipher = fragments_crypto.createDecipher(
      fragments_encryptionAlgorithm
      password
    )
    decrypted = decipher.update(textToDecrypt, 'hex', 'utf8')
    decrypted += decipher.final('utf8')
    return decrypted
