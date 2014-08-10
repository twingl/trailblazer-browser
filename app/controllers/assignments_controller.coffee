Twingl.AssignmentsController = Ember.Controller.extend
  needs: ['application', 'tree']

  actions:
    setAssignment: (assignment) ->
      @get("controllers.application").set("assignment", assignment)
      @transitionToRoute('browser')
