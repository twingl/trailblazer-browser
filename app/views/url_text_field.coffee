Twingl.UrlTextField = Ember.TextField.extend
  classNames  : [ 'tb-url-input' ]
  placeholder : 'http://example.com'
  action      : "navigateUrl"
  attributeBindings: ['value']

  insertNewline: -> @sendAction()
