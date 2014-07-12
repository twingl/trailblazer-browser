Twingl.WindowCloseButton = Ember.Component.extend
  tagName   : "i"
  classNames: ["tb-window-close", "tb-window-control", "fa", "fa-times"]
  action    : "closeWindow"

  click: ->
    @sendAction()
