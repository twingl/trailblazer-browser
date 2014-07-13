Twingl.AssignmentSwitcher = Ember.Component.extend
  tagName   : "button"
  classNames: [ "tb-assignment-switch", "tb-window-nav" ]
  action    : "showAssignments"
  layoutName: "windowNavigation/assignment_switcher"

  click: ->
    @sendAction()
