Twingl.UrlTextField = Ember.TextField.extend
  classNames  : [ 't-url-input' ]
  placeholder : 'http://example.com'
  action      : "navigateUrl"
  attributeBindings: ['value']

  insertNewline: -> @sendAction()
