Twingl.UrlSubmitButton = Ember.Component.extend
  tagName   : 'button'
  classNames: [ 't-url-submit', 't-nav-button' ]
  action    : "navigateUrl"
  layoutName: "button"
  text      : "Go"

  click: -> @sendAction()
