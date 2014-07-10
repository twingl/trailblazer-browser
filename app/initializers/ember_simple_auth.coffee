###
# Configure SimpleAuth
###
window.ENV ||= {}
window.ENV['simple-auth'] =
  store:      'simple-auth-session-store:ephemeral'
  authorizer: 'simple-auth-authorizer:oauth2-bearer'

OAuth2Authenticator = SimpleAuth.Authenticators.Base.extend
  restore: (properties) ->

  authenticate: (credentials) ->
    new Ember.RSVP.Promise (resolve, reject) ->
      authUrl  = "http://localhost:3000/oauth/authorize"
      redirect = encodeURIComponent "https://#{chrome.runtime.id}.chromiumapp.org/"
      clientId = "3e28871e11e0f4bf55e464bc20cd1774eb8da855a470b5eda766fed6f78943f3"

      url = "#{authUrl}?client_id=#{clientId}&response_type=token&redirect_uri=#{redirect}"

      chrome.identity.launchWebAuthFlow {'url': url, 'interactive': true}, (redirectUrl) ->
        # Form an object from the redirect URL hash
        accessToken = redirectUrl.substring(redirectUrl.indexOf("#") + 1)
        o = {}
        for item in accessToken.split('&')
          i = item.split('=')
          o[i[0]] = i[1]
        resolve(o)

  invalidate: (data) ->
    new Ember.RSVP.Promise (resolve, reject) ->
      body = { token: data['access_token'] }
      url  = "http://localhost:3000/oauth/revoke"
      Ember.$.ajax
        url:         url
        type:        'POST'
        data:        body
        dataType:    'json'
        contentType: 'application/x-www-form-urlencoded'
        error:       reject
        success:     resolve

Ember.Application.initializer
  name: 'authentication'
  before: 'simple-auth'
  initialize: (container, application) ->
    container.register 'twingl:authenticators:oauth2', OAuth2Authenticator
