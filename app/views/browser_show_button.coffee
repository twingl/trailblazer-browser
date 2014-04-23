Twingl.BrowserShowButton = Ember.Component.extend
  tagName   : 'button'
  classNames: [ 't-browser-show', 't-nav-button' ]
  action    : "browserShow"
  layoutName: "button"
  text      : "Back"

  click: ->
    @sendAction()
