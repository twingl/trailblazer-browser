Twingl.WindowMinimizeButton = Ember.Component.extend
  tagName   : "i"
  classNames: ["tb-window-minimize", "tb-chrome-button", "fa", "fa-minus"]
  action    : "minimizeWindow"

  click: ->
    @sendAction()
