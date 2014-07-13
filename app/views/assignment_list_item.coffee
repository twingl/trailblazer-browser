Twingl.AssignmentListItem = Ember.Component.extend
  tagName   : 'li'
  classNames: []
  action    : "setAssignment"
  layoutName: "main/assignments/list_item"

  click: ->
    @sendAction('action', @assignment)
