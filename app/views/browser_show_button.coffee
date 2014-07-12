Twingl.BrowserShowButton = Ember.Component.extend
  tagName   : 'button'
  classNames: [ 'tb-browser-show', 'tb-nav-button' ]
  action    : "browserShow"
  layoutName: "button"
  text      : "Back"

  click: ->
    @sendAction()
