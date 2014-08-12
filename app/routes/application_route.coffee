Twingl.ApplicationRoute = Ember.Route.extend SimpleAuth.ApplicationRouteMixin,
  actions:
    sessionAuthenticationSucceeded: ->
      console.log "logged in"
      # Transition to the assignment selection page
      @transitionTo 'assignments'

    sessionAuthenticationFailed: (error) ->
      console.log "failed to log in", error

    authorizationFailed: (error) ->
      console.log "failed to authorize", error

    sessionInvalidationSucceeded: ->
      console.log "logged out"
      @get('controller').send('resetState')

    sessionInvalidationFailed: (error) ->
      console.log "failed to log out", error
