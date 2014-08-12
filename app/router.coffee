Twingl.Router.map ->
  # The initial entry point for the app.
  # Users will initiate the OAuth2 flow from here
  #
  # /login
  @route 'login'

  # Top level loading route - Ember automatically transitions to this during
  # long-running transitions
  #
  # /loading
  @route 'loading'

  # Assignments selection interface shown after login
  #
  # /assignments
  @resource 'assignments', ->

  # The browsing and trail interface - transitioned to when an assignment has
  # been selected
  #
  # /assignments/:assignment_id/browser
  @route 'browser', path: "/assignments/:assignment_id/browser"
