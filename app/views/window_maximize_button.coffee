Twingl.WindowMaximizeButton = Ember.Component.extend
  tagName   : "i"
  classNames: ["tb-window-maximize", "tb-window-control", "fa", "fa-plus"]
  action    : "maximizeWindow"

  click: ->
    @sendAction()
