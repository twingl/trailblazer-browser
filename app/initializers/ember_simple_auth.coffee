window.ChromeAuth =
  authenticate: (resolve, reject) ->
    authUrl  = "#{window.ENV['api_host']}/oauth/authorize"
    redirect = encodeURIComponent "https://#{chrome.runtime.id}.chromiumapp.org/"
    clientId = "f2c3d77a1a31f9149d92c9c02a030787e4c4d3531727f5b6732e379454d246ed"

    url = "#{authUrl}?client_id=#{clientId}&response_type=token&redirect_uri=#{redirect}"

    chrome.identity.launchWebAuthFlow {'url': url, 'interactive': true}, (redirectUrl) ->
      # Form an object from the redirect URL hash
      response = redirectUrl.substring(redirectUrl.indexOf("#") + 1)
      responseObject = {}
      for item in response.split('&')
        i = item.split('=')
        responseObject[i[0]] = i[1]

      if responseObject.access_token
        resolve(responseObject)
      else
        reject(responseObject)

  invalidate: (data, resolve, reject) ->
    body = { token: data['access_token'] }
    url  = "#{window.ENV['api_host']}/oauth/revoke"
    Ember.$.ajax
      url:         url
      type:        'POST'
      data:        body
      dataType:    'json'
      contentType: 'application/x-www-form-urlencoded'
      error:       reject
      success:     resolve

OAuth2Authenticator = SimpleAuth.Authenticators.Base.extend
  restore: (properties) ->

  authenticate: (credentials) ->
    new Ember.RSVP.Promise (resolve, reject) ->
      ChromeAuth.authenticate(resolve, reject)

  invalidate: (data) ->
    new Ember.RSVP.Promise (resolve, reject) ->
      ChromeAuth.invalidate(data, resolve, reject)

Ember.Application.initializer
  name: 'authentication'
  before: 'simple-auth'
  initialize: (container, application) ->
    container.register 'twingl:authenticators:oauth2', OAuth2Authenticator
