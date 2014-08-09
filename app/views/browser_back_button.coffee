Twingl.BrowserBackButton = Ember.Component.extend
  tagName   : "i"
  classNames: [ "tb-browser-back", "tb-nav-button", "fa", "fa-arrow-circle-left" ]
  action    : "browserBack"

  click: ->
    @sendAction()
