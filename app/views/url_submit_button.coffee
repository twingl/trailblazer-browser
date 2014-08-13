Twingl.UrlSubmitButton = Ember.Component.extend
  tagName   : 'button'
  classNames: [ 'tb-url-submit', 'tb-nav-button' ]
  action    : "navigateUrl"
  layoutName: "components/button"
  text      : "Go"

  click: -> @sendAction()
