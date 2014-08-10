Twingl.WindowMaximizeButton = Ember.Component.extend
  tagName   : "i"
  classNames: ["tb-window-maximize", "tb-chrome-button", "fa", "fa-plus"]
  action    : "maximizeWindow"

  click: ->
    @sendAction()
