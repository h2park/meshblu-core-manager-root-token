_                = require 'lodash'
bcrypt           = require 'bcrypt'
crypto           = require 'crypto'
mongojs          = require 'mongojs'
Datastore        = require 'meshblu-core-datastore'
RootTokenManager = require '../'

describe 'RootTokenManager', ->
  beforeEach (done) ->
    @pepper = 'im-a-pepper'
    @uuidAliasResolver = resolve: (uuid, callback) => callback(null, uuid)
    database = mongojs 'root-token-manager-test', ['things']
    @datastore = new Datastore
      database: database
      collection: 'things'
    database.things.remove done

  beforeEach ->
    @sut = new RootTokenManager {@uuidAliasResolver, @datastore, @pepper}

  beforeEach (done) ->
    @datastore.insert { uuid: 'spiral' }, done

  describe 'when called', ->
    beforeEach (done) ->
      @sut.generateAndStoreToken { uuid: 'spiral' }, (error, @generatedToken) =>
        done error

    describe 'when the record is retrieved', ->
      beforeEach (done) ->
        @datastore.findOne { uuid: 'spiral' }, (error, @record) =>
          done error

      it 'should match the generated token', (done) ->
        @sut.verifyToken { uuid: 'spiral', token: @generatedToken }, (error, valid) =>
          return done error if error?
          expect(valid).to.be.true
          done()
