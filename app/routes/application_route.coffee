Twingl.ApplicationRoute = Ember.Route.extend SimpleAuth.ApplicationRouteMixin,
  actions:
    # These actions are fired by Ember Simple Auth.
    # See http://ember-simple-auth.simplabs.com/ember-simple-auth-api-docs.html
    # for details, under SimpleAuth.ApplicationRouteMixin's "Actions" section
    sessionAuthenticationSucceeded: ->
      console.log "logged in"
      # Transition to the assignments index
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
