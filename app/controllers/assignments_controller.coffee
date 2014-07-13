Twingl.AssignmentsController = Ember.Controller.extend
  needs: ['application']

  actions:
    setAssignment: (assignment) ->
      @get("controllers.application").set("assignment", assignment)
      @transitionToRoute('browser')
