should = require 'should'

noErr = (f) -> (err, rest...) ->
  should.not.exist err
  f(rest...)

noUser = (app, email) -> "There is no user with the email '#{email}' for the app '#{app}'"
noApp = (app) -> "Could not find an app with the name '#{app}'"

isError = (err, msg) ->
  err.should.be.an.instanceof Error
  err.message.should.eql msg
  err.toString().should.eql "Error: #{msg}"



exports.runTests = (storeCreator, clean) ->

  describe 'the store, when first connected to,', ->

    store = null

    beforeEach (done) ->
      store = storeCreator()
      done()

    it "should already have a locke app", (done) ->
      store.createUser 'locke', 'email@test.com', { password: 'psspww' }, noErr ->
        done()

    it "should already have a locke app", (done) ->
      store.createApp 'test@user.com', 'locke', (err) ->
        isError err, noUser('locke', 'test@user.com')
        done()

    it "should already have a locke app", (done) ->
      store.removeUser 'locke', 'test@user.com', (err) ->
        isError err, noUser('locke', 'test@user.com')
        done()

    it "should already have a locke app", (done) ->
      store.getUser 'locke', 'test@user.com', noErr (data) ->
        should.not.exist data
        done()

    it "should already have a locke app", (done) ->
      store.setUserData 'locke', 'test@user.com', {}, (err) ->
        isError err, noUser('locke', 'test@user.com')
        done()

    it "should already have a locke app", (done) ->
      store.removeAllTokens 'locke', 'test@user.com', 'auth', (err) ->
        isError err, noUser('locke', 'test@user.com')
        done()

    it "should already have a locke app", (done) ->
      store.comparePassword 'locke', 'test@user.com', 'password', (err) ->
        isError err, noUser('locke', 'test@user.com')
        done()

    it "should already have a locke app", (done) ->
      store.compareToken 'locke', 'test@user.com', 'type', 'name', (err) ->
        isError err, noUser('locke', 'test@user.com')
        done()

    it "should already have a locke app", (done) ->
      store.addToken 'locke', 'test@user.com', 'type', 'name', {}, (err) ->
        isError err, noUser('locke', 'test@user.com')
        done()

    it "should already have a locke app", (done) ->
      store.removeToken 'locke', 'test@user.com', 'auth', 'name', (err) ->
        isError err, noUser('locke', 'test@user.com')
        done()

    it "should already have a locke app", (done) ->
      store.deleteApp 'locke', (err) ->
        isError(err, "It is not possible to delete the app 'locke'")
        done()

    it "should already have a locke app", (done) ->
      store.getApps 'test@user.com', (err) ->
        isError err, noUser('locke', 'test@user.com')
        done()



  describe 'the store', ->

    demoApp = (name, callback) ->
      store.createUser 'locke', 'something-something-unqiue@mail.com', { password: 'some-password' }, noErr ->
        store.createApp 'something-something-unqiue@mail.com', name, noErr ->
          callback()

    store = storeCreator()

    beforeEach (done) ->
      clean(store, done)

    ##
    ## Interface
    ##

    it "should expose the right methods", ->
      methods = [
        'comparePassword'
        'compareToken'
        'addToken'
        'removeToken'
        'removeAllTokens'
        'setUserData'
        'getUser'
        'createUser'
        'removeUser'
        'createApp'
        'getApps'
        'deleteApp'
      ]
      Object.keys(store).should.include(methods...)



    ##
    ## 1. authentication
    ##

    it "should allow creating a user, and successfully authenticating, for the locke-app", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'pwwpas' }, noErr ->
        store.comparePassword 'locke', 'test@user.com', 'pwwpas', noErr (status) ->
          status.should.eql true
          store.addToken 'locke', 'test@user.com', 'auth', 'token-name', { }, noErr ->
            store.compareToken 'locke', 'test@user.com', 'auth', 'token-name', noErr ->
              done()

    it "should prevent attempts to create a user for a non-existing app", (done) ->
      store.createUser 'does-not-exist', 'test@user.com', { password: 'pwwpas' }, (err) ->
        isError err, noApp('does-not-exist')
        done()

    it "should prevent attempts to create a user that already exists", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'some_password' }, noErr ->
        store.createUser 'locke', 'test@user.com', { password: 'another_password' }, (err) ->
          isError err, "User 'test@user.com' already exists for the app 'locke'"
          done()

    it "should allow creating a user with a very short password", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'a' }, noErr ->
        done()

    it "should not allow creating a user with a password that is not a string", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 56 }, (err) ->
        isError err, 'Password must be a non-empty string'
        done()

    it "should not allow creating a user with a password that is an empty string", (done) ->
      store.createUser 'locke', 'test@user.com', { password: '' }, (err) ->
        isError err, 'Password must be a non-empty string'
        done()

    it "should not allow the user data object to be left out when creating a user", (done) ->
      store.createUser 'locke', 'test@user.com', null, (err) ->
        isError err, 'Password cannot be null'
        done()

    it "should not allow null-passwords", (done) ->
      store.createUser 'locke', 'test@user.com', { password: null }, (err) ->
        isError err, 'Password cannot be null'
        done()

    it "should not allow lack of password when creating a user", (done) ->
      store.createUser 'locke', 'test@user.com', { }, (err) ->
        isError err, 'Password cannot be null'
        done()

    it "should not allow undefined-passwords", (done) ->
      store.createUser 'locke', 'test@user.com', { password: undefined }, (err) ->
        isError err, 'Password cannot be null'
        done()

    it "should allow creating a user with a very common password", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'abc123' }, noErr ->
        done()

    it "should prevent attempts to authenticate for a non-existing app", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'some_password' }, noErr ->
        store.comparePassword 'non-existing48585238', 'test@user.com', 'some_password', (err) ->
          isError err, noApp('non-existing48585238')
          done()

    it "should prevent attempts to authenticate for a non-existing user", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'some_password' }, noErr ->
        store.comparePassword 'locke', 'non-existing-user123', 'some_password', (err) ->
          isError err, noUser('locke', 'non-existing-user123')
          done()

    it "should prevent attempts to authenticate with an invalid password", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'some_password' }, noErr ->
        store.comparePassword 'locke', 'test@user.com', 'another_password', noErr (status) ->
          status.should.eql false
          done()

    it "should allow anything to be passed in as token data", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'some_password' }, noErr ->
        store.addToken 'locke', 'test@user.com', 'auth', 'token-name', { data: 'foobar', nested: { one: 1 } }, noErr ->
          store.compareToken 'locke', 'test@user.com', 'auth', 'token-name', noErr (info) ->
            info.should.eql { data: 'foobar', nested: { one: 1 } }
            done()

    it "should allow 'undefined' to be passed in as token data", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'some_password' }, noErr ->
        store.addToken 'locke', 'test@user.com', 'auth', 'token-name', undefined, noErr ->
          store.compareToken 'locke', 'test@user.com', 'auth', 'token-name', noErr (info) ->
            should.not.exist info
            done()

    it "should allow 'null' to be passed in as token data", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'some_password' }, noErr ->
        store.addToken 'locke', 'test@user.com', 'auth', 'token-name', null, noErr ->
          store.compareToken 'locke', 'test@user.com', 'auth', 'token-name', noErr (info) ->
            should.not.exist info
            done()

    it "should prevent authentication using an invalid app name", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'pwwpas' }, noErr ->
        store.addToken 'locke', 'test@user.com', 'auth', 'token-name', { }, noErr ->
          store.compareToken 'non-existing48585238', 'test@user.com', 'auth', 'token-name', (err) ->
            isError err, noApp('non-existing48585238')
            done()

    it "should prevent authentication using an invalid username", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'pwwpas' }, noErr ->
        store.addToken 'locke', 'test@user.com', 'auth', 'token-name', { }, noErr ->
          store.compareToken 'locke', 'non-existing534752735', 'auth', 'token-name', (err) ->
            isError err, noUser('locke', 'non-existing534752735')
            done()

    it "should prevent authentication using an incorrect token label", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'pwwpas' }, noErr ->
        store.addToken 'locke', 'test@user.com', 'auth', 'token-name', { }, noErr ->
          store.compareToken 'locke', 'test@user.com', 'auth-other', 'token-name', (err) ->
            isError err, "Incorrect token"
            done()

    it "should prevent authentication using an incorrect token value", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'pwwpas' }, noErr ->
        store.addToken 'locke', 'test@user.com', 'auth', 'token-name', { }, noErr ->
          store.compareToken 'locke', 'test@user.com', 'auth', 'token-name-other', (err) ->
            isError err, "Incorrect token"
            done()

    it "should prevent authentication using another users password", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'some-password' }, noErr ->
        store.createUser 'locke', 'test2@user.com', { password: 'other-password' }, noErr ->
          store.comparePassword 'locke', 'test@user.com', 'other-password', noErr (status) ->
            status.should.eql false
            done()

    it "should prevent authentication using another users token", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'some-password' }, noErr ->
        store.createUser 'locke', 'test2@user.com', { password: 'other-password' }, noErr ->
          store.addToken 'locke', 'test@user.com', 'auth', 'token-name-1', { }, noErr ->
            store.addToken 'locke', 'test2@user.com', 'auth', 'token-name-2', { }, noErr ->
              store.compareToken 'locke', 'test@user.com', 'auth', 'token-name-2', (err) ->
                isError err, "Incorrect token"
                done()

    it "should allow authentication using an old, but still valid, token", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'some-password' }, noErr ->
        store.addToken 'locke', 'test@user.com', 'auth', 'token-name-1', { }, noErr ->
          store.addToken 'locke', 'test@user.com', 'auth', 'token-name-2', { }, noErr ->
            store.compareToken 'locke', 'test@user.com', 'auth', 'token-name-2', noErr (val) ->
              val.should.eql {}
              done()



    ##
    ## 4. apps
    ##

    it "should allow authentication using an old, but still valid, token", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'some-password' }, noErr ->
        store.createApp 'test@user.com', 'myapp', noErr ->
          store.createUser 'myapp', 'sally@user.com', { password: 'sallyp'}, noErr ->
            store.getApps 'test@user.com', noErr (data) ->
              data.should.eql {
                myapp:
                  userCount: 1
              }
              done()

    it "should prevent apps from being created without an email of an actual locke-user", (done) ->
      store.createApp 'test@user.com', 'myapp', (err) ->
        isError err, noUser('locke', 'test@user.com')
        done()


    it "should prevent the user from creating an app called locke", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'some-password' }, noErr ->
        store.createApp 'test@user.com', 'locke', (err) ->
          isError err, "App name 'locke' is already in use"
          done()

    it "should prevent the user from defining a new app name that has already been created by the same user", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'some-password' }, noErr ->
        store.createApp 'test@user.com', 'sally', noErr ->
          store.createApp 'test@user.com', 'sally', (err) ->
            isError err, "App name 'sally' is already in use"
            done()

    it "should prevent the user from defining an app name that another user has already taken", (done) ->
      store.createUser 'locke', 'test1@user.com', { password: 'some-password' }, noErr ->
        store.createUser 'locke', 'test2@user.com', { password: 'some-password' }, noErr ->
          store.createApp 'test1@user.com', 'sally', noErr ->
            store.createApp 'test2@user.com', 'sally', (err) ->
              isError err, "App name 'sally' is already in use"
              done()

    it "should prevent non-existing users from getting lists of apps", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'some-password' }, noErr ->
        store.createApp 'test@user.com', 'myapp', noErr ->
          store.getApps 'non-existing@user.com', (err) ->
            isError err, noUser('locke', 'non-existing@user.com')
            done()

    it "should prevent non-locke users from getting lists of apps", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'some-password' }, noErr ->
        store.createApp 'test@user.com', 'myapp', noErr ->
          store.createUser 'myapp', 'myapp@user.com', { password: 'some-password' }, noErr ->
            store.getApps 'myapp@user.com', (err) ->
              isError err, noUser('locke', 'myapp@user.com')
              done()

    it "should be possible to create multiple apps", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'some-password' }, noErr ->
        store.createApp 'test@user.com', 'myapp', noErr ->
          store.createApp 'test@user.com', 'sally', noErr ->
            store.createApp 'test@user.com', 'rester', noErr ->
              store.getApps 'test@user.com', noErr (data) ->
                data.should.eql {
                  myapp: { userCount: 0 }
                  sally: { userCount: 0 }
                  rester: { userCount: 0 }
                }
                done()

    it "should be possible list user count when there are multiple locke-users with apps", (done) ->
      store.createUser 'locke', 'test1@user.com', { password: 'some-password' }, noErr ->
        store.createUser 'locke', 'test2@user.com', { password: 'some-password' }, noErr ->
          store.createApp 'test1@user.com', 'myapp', noErr ->
            store.createApp 'test1@user.com', 'sally', noErr ->
              store.createApp 'test2@user.com', 'rester', noErr ->
                store.createUser 'rester', 'test3@user.com', { password: 'some-password' }, noErr ->
                  store.createUser 'rester', 'test4@user.com', { password: 'some-password' }, noErr ->
                    store.createUser 'myapp', 'test5@user.com', { password: 'some-password' }, noErr ->
                      store.getApps 'test1@user.com', noErr (data) ->
                        data.should.eql {
                          myapp: { userCount: 1 }
                          sally: { userCount: 0 }
                        }
                        store.getApps 'test2@user.com', noErr (data) ->
                          data.should.eql {
                            rester: { userCount: 2 }
                          }
                          done()

    it "should be possible list user count when there are multiple locke-users with apps", (done) ->
      store.createUser 'locke', 'test1@user.com', { password: 'some-password' }, noErr ->
        store.createApp 'test1@user.com', 'myapp', noErr ->
          store.createUser 'myapp', 'test2@user.com', { password: 'some-other-password' }, noErr ->
            store.comparePassword 'myapp', 'test2@user.com', 'some-other-password', noErr (status) ->
              status.should.eql true
              done()

    ##
    ## 5. closing sessions
    ##

    it "should allow removing a token", (done) ->
      demoApp 'sally', ->
        store.createUser 'sally', 'test@user.com', { password: 'some-password' }, noErr ->
          store.addToken 'sally', 'test@user.com', 'auth', 'token-name-1', { }, noErr ->
            store.compareToken 'sally', 'test@user.com', 'auth', 'token-name-1', noErr (val) ->
              val.should.eql {}
              store.removeToken 'sally', 'test@user.com', 'auth', 'token-name-1', noErr ->
                store.compareToken 'sally', 'test@user.com', 'auth', 'token-name-1', (err) ->
                  isError err, 'Incorrect token'
                  done()

    it "should allow removing all tokens at once", (done) ->
      demoApp 'sally', ->
        store.createUser 'sally', 'test@user.com', { password: 'some-password' }, noErr ->
          store.addToken 'sally', 'test@user.com', 'auth', 'token-name-1', { }, noErr ->
            store.addToken 'sally', 'test@user.com', 'auth', 'token-name-2', { }, noErr ->
              store.removeAllTokens 'sally', 'test@user.com', 'auth', noErr ->
                store.compareToken 'sally', 'test@user.com', 'auth', 'token-name-1', (err) ->
                  isError err, 'Incorrect token'
                  store.compareToken 'sally', 'test@user.com', 'auth', 'token-name-2', (err) ->
                    isError err, 'Incorrect token'
                    done()

    it "should let all tokens except the removed one remain valid", (done) ->
      demoApp 'sally', ->
        store.createUser 'sally', 'test@user.com', { password: 'some-password' }, noErr ->
          store.addToken 'sally', 'test@user.com', 'auth', 'token-name-1', { }, noErr ->
            store.addToken 'sally', 'test@user.com', 'auth', 'token-name-2', { }, noErr ->
              store.removeToken 'sally', 'test@user.com', 'auth', 'token-name-1', noErr ->
                store.compareToken 'sally', 'test@user.com', 'auth', 'token-name-1', (err) ->
                  isError err, 'Incorrect token'
                  store.compareToken 'sally', 'test@user.com', 'auth', 'token-name-2', noErr (val) ->
                    val.should.eql {}
                    done()

    it "should not be possible to remove a token for a non-existing app", (done) ->
      store.removeToken 'sally', 'test@user.com', 'auth', 'token-name-1', (err) ->
        isError err, noApp('sally')
        done()

    it "should not be possible to remove a token for a non-existing user", (done) ->
      demoApp 'sally', ->
        store.removeToken 'sally', 'test@user.com', 'auth', 'token-name-1', (err) ->
          isError err, noUser('sally', 'test@user.com')
          done()

    it "should be possible to remove a single token from a user", (done) ->
      demoApp 'sally', ->
        store.createUser 'sally', 'test@user.com', { password: 'sallyp' }, noErr ->
          store.removeToken 'sally', 'test@user.com', 'abc', 'token-name-1', noErr ->
            done()

    it "should not be possible to remove all tokens for a non-existing app", (done) ->
      store.removeAllTokens 'sally', 'test@user.com', 'auth', (err) ->
        isError err, noApp('sally')
        done()

    it "should not be possible to remove all tokens for a non-existing user", (done) ->
      demoApp 'sally', ->
        store.removeAllTokens 'sally', 'test@user.com', 'auth', (err) ->
          isError err, noUser('sally', 'test@user.com')
          done()

    it "should be possible to remove all tokens from a user", (done) ->
      demoApp 'sally', ->
        store.createUser 'sally', 'test@user.com', { password: 'sallyp' }, noErr ->
          store.removeAllTokens 'sally', 'test@user.com', 'abc', noErr ->
            done()

    it "...", (done) ->
      demoApp 'sally', ->
        store.createUser 'sally', 'test1@user.com', { password: 'sallyp' }, noErr ->
          store.createUser 'sally', 'test2@user.com', { password: 'sallyp' }, noErr ->
            store.addToken 'sally', 'test1@user.com', 'auth', 'token-name-1', { }, noErr ->
              store.addToken 'sally', 'test2@user.com', 'auth', 'token-name-2', { }, noErr ->
                store.removeAllTokens 'sally', 'test1@user.com', 'auth', noErr ->
                  store.compareToken 'sally', 'test2@user.com', 'auth', 'token-name-2', noErr (val) ->
                    val.should.eql {}
                    done()

    ##
    ## 6. deleting user
    ##
    it "should allow users to be deleted", (done) ->
      demoApp 'sally', ->
        store.createUser 'sally', 'test@user.com', { password: 'sallyp' }, noErr ->
          store.removeUser 'sally', 'test@user.com', noErr ->
            store.comparePassword 'sally', 'test@user.com', 'sallyp', (err) ->
              isError err, noUser('sally', 'test@user.com')
              done()

    it "should raise an error when trying to remove a user from an app that does not exist", (done) ->
      store.removeUser 'sally', 'test@user.com', (err) ->
        isError err, noApp('sally')
        done()

    it "should raise an error when trying to remove a user that does not exist", (done) ->
      store.removeUser 'locke', 'test@user.com', (err) ->
        isError err, noUser('locke', 'test@user.com')
        done()

    ##
    ## 7. updatePassword
    ##

    it "should be possible to change password", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'some-password' }, noErr ->
        store.setUserData 'locke', 'test@user.com', { password: 'updated-password' }, noErr ->
          store.comparePassword 'locke', 'test@user.com', 'updated-password', noErr (status) ->
            status.should.eql true
            done()

    it "should not be possible to change password for a user that does not exist", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'some-password' }, noErr ->
        store.setUserData 'locke', 'test@user.com', { password: 'updated-password' }, noErr ->
          store.comparePassword 'locke', 'test2@user.com', 'updated-password', (err) ->
            isError err, noUser('locke', 'test2@user.com')
            done()

    it "should not be possible to change password to a null-password", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'some-password' }, noErr ->
        store.setUserData 'locke', 'test@user.com', { password: null }, (err) ->
          isError err, 'Password cannot be null'
          done()

    it "should not be possible to change password to something that is not a string", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'some-password' }, noErr ->
        store.setUserData 'locke', 'test@user.com', { password: 56 }, (err) ->
          isError err, 'Password must be a non-empty string'
          done()

    it "should not be possible to change password to the empty string", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'some-password' }, noErr ->
        store.setUserData 'locke', 'test@user.com', { password: '' }, (err) ->
          isError err, 'Password must be a non-empty string'
          done()

    ##
    ## 8. Deleting apps
    ##

    it "should be possible to delete an app", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'some-password' }, noErr ->
        store.createApp 'test@user.com', 'demo', noErr ->
          store.deleteApp 'demo', noErr ->
            store.getApps 'test@user.com', noErr (data) ->
              data.should.eql {}
              done()

    it "should not be possible to delete the locke app", (done) ->
      store.deleteApp 'locke', (err) ->
        isError(err, "It is not possible to delete the app 'locke'")
        done()


    ##
    ## övrigt
    ##

    it "should be possible to get all user data", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'test', data: 'foobar', nested: { one: 1 } }, noErr ->
        store.getUser 'locke', 'test@user.com', noErr (data) ->
          # This can contain more data, if the implementation has chosen to put it there,
          # but it has to contain these at the very minimum
          # The password itself is not nessesarily stored as the plain password, but it has to be stored as something
          data.password.should.be.a 'string'
          data.password.length.should.be.above 0
          data.data.should.eql 'foobar'
          data.nested.should.eql { one: 1 }
          done()

    it "should not be possible to get user data for an app that does not exist", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'test' }, noErr ->
        store.getUser 'locke2', 'test@user.com', (err) ->
          isError err, noApp('locke2')
          done()

    it "should not be possible to get user data for a user that does not exist", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'test' }, noErr ->
        store.getUser 'locke', 'test2@user.com', noErr (data) ->
          should.not.exist null
          done()

    it "should not be possible to run setUserData with an invalid app", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'test' }, noErr ->
        store.setUserData 'locke2', 'test@user.com', { x: 1 }, (err) ->
          isError err, noApp('locke2')
          done()

    it "should not be possible to run setUserData with an invalid user", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'test' }, noErr ->
        store.setUserData 'locke', 'test2@user.com', { x: 1 }, (err) ->
          isError err, noUser('locke', 'test2@user.com')
          done()

    it "should not be possible to run addToken with an invalid app", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'test' }, noErr ->
        store.addToken 'locke2', 'test@user.com', 'type', 'name', 'value', (err) ->
          isError err, noApp('locke2')
          done()

    it "should not be possible to run addToken with an invalid user", (done) ->
      store.createUser 'locke', 'test@user.com', { password: 'test' }, noErr ->
        store.addToken 'locke', 'test2@user.com', 'type', 'name', 'value', (err) ->
          isError err, noUser('locke', 'test2@user.com')
          done()

    it "should not be possible to delete an app that does not exist", (done) ->
      store.deleteApp 'non-existing', (err) ->
        isError err, noApp('non-existing')
        done()
