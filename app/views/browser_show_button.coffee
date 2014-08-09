Twingl.BrowserShowButton = Ember.Component.extend
  tagName   : "i"
  classNames: [ "tb-browser-show", "tb-nav-button", "fa", "fa-globe" ]
  action    : "browserShow"

  click: ->
    @sendAction()
