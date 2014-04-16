Twingl.WebviewController = Ember.Controller.extend
  url: ''

  navigate: (url) ->
    @set 'url', url
