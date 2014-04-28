Twingl.ApplicationRoute = Ember.Route.extend Ember.SimpleAuth.ApplicationRouteMixin,
  actions:
    sessionAuthenticationSucceeded: ->
      console.log "logged in"
      @transitionTo 'index' # Transition to the application

    sessionAuthenticationFailed: (error) ->
      console.log "failed to log in", error

    authorizationFailed: (error) ->
      console.log "failed to authorize", error


    sessionInvalidationSucceeded: ->
      console.log "logged out"
      Twingl.reset() # Clear application state

    sessionInvalidationFailed: (error) ->
      console.log "failed to log out", error
