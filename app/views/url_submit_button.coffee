Twingl.UrlSubmitButton = Ember.Component.extend
  tagName   : 'button'
  classNames: [ 'tb-url-submit', 'tb-nav-button' ]
  action    : "navigateUrl"
  layoutName: "button"
  text      : "Go"

  click: -> @sendAction()
