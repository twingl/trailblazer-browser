Twingl.WindowMinimizeButton = Ember.Component.extend
  tagName   : "i"
  classNames: ["tb-window-minimize", "tb-window-control", "fa", "fa-minus"]
  action    : "minimizeWindow"

  click: ->
    @sendAction()
