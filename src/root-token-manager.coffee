bcrypt = require 'bcrypt'
crypto = require 'crypto'

class RootTokenManager
  constructor: ({@datastore,@uuidAliasResolver}) ->

  generateAndStoreToken: ({ uuid }, callback) =>
    @uuidAliasResolver.resolve uuid, (error, uuid) =>
      return callback error if error?
      token = @_generateToken()
      @_hashToken token, (error, hashedToken) =>
        return callback error if error?
        @datastore.update { uuid }, { $set: { token: hashedToken }}, (error) =>
          return callback error if error?
          callback null, token

  verifyToken: ({ uuid, token }, callback) =>
    return callback null, false unless uuid? and token?
    @uuidAliasResolver.resolve uuid, (error, uuid) =>
      return callback error if error?
      projection = { uuid: true, token: true }
      @datastore.findOne { uuid }, projection, (error, device) =>
        return callback error if error?
        return callback null, false unless device?
        hashedToken = device.token
        @_verifyTokenHash { token, hashedToken }, callback

  _generateToken: =>
    return crypto.createHash('sha1').update((new Date()).valueOf().toString() + Math.random().toString()).digest('hex')

  _hashToken: (token, callback) =>
    bcrypt.hash token, 8, callback

  _verifyTokenHash: ({ token, hashedToken }, callback) =>
    return callback null, false unless token?
    return callback null, false unless hashedToken?
    bcrypt.compare token, hashedToken, callback

module.exports = RootTokenManager
