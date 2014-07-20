OAuth2Authenticator = SimpleAuth.Authenticators.Base.extend
  restore: (properties) ->

  authenticate: (credentials) ->
    new Ember.RSVP.Promise (resolve, reject) ->
      authUrl  = "#{window.ENV['api_host']}/oauth/authorize"
      redirect = encodeURIComponent "https://#{chrome.runtime.id}.chromiumapp.org/"
      clientId = "f2c3d77a1a31f9149d92c9c02a030787e4c4d3531727f5b6732e379454d246ed"

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
