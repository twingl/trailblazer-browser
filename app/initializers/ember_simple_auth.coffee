Ember.Application.initializer
  name: 'authentication'
  initialize: (container, application) ->
    Ember.SimpleAuth.Authenticators.OAuth2.reopen
      serverTokenEndpoint: 'https://api.twin.gl/oauth/token'
      makeRequest: (data) ->
        data.client_id     = 'c8d49e1fb688a4c15eb2a42eaacdd7bbeffe14fcfe35441825eb77e6f8be1a27'
        data.client_secret = 'f2ca763d681ac8b3319e88f93d7154ccad696010bc0c69da54713631c6991dd4'
        @_super data

    Ember.SimpleAuth.setup container, application,
      crossOriginWhitelist: [ 'https://api.twin.gl' ]
      storeFactory: 'session-store:ephemeral' #TODO implement a persistent store
      authorizerFactory: 'authorizer:oauth2-bearer'
