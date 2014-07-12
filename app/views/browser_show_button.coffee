Twingl.BrowserShowButton = Ember.Component.extend
  tagName   : "i"
  classNames: [ "tb-browser-show", "tb-nav-button", "fa", "fa-arrow-left" ]
  action    : "browserShow"

  click: ->
    @sendAction()
