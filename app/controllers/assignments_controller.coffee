Twingl.AssignmentsController = Ember.Controller.extend
  needs: ['application', 'tree']

  actions:
    setAssignment: (assignment) ->
      @get("controllers.application").set("assignment", assignment)
      @transitionToRoute('loading')
      @get("controllers.tree").send 'loadHistory', => @transitionToRoute('browser')
