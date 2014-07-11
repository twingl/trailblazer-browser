Twingl.ApplicationRoute = Ember.Route.extend SimpleAuth.ApplicationRouteMixin,
  actions:
    sessionAuthenticationSucceeded: ->
      console.log "logged in"
      @transitionTo 'assignments' # Transition to the application

    sessionAuthenticationFailed: (error) ->
      console.log "failed to log in", error

    authorizationFailed: (error) ->
      console.log "failed to authorize", error

    sessionInvalidationSucceeded: ->
      console.log "logged out"
      @get('controller').send('resetState')

    sessionInvalidationFailed: (error) ->
      console.log "failed to log out", error
