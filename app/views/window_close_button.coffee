Twingl.WindowCloseButton = Ember.Component.extend
  tagName   : "i"
  classNames: ["tb-window-close", "tb-chrome-button", "fa", "fa-times"]
  action    : "closeWindow"

  click: ->
    @sendAction()
