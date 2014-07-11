Twingl.AssignmentListItem = Ember.Component.extend
  tagName   : 'li'
  classNames: []
  action    : "setAssignment"
  layoutName: "assignments/list_item"

  click: ->
    @sendAction('action', @assignment)
