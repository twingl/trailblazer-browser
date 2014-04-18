Twingl.Webview = Ember.View.extend
  tagName   : 'webview'
  attributeBindings: ['src']

#  webviewClose:             (evt) -> console.log(evt)
#  webviewConsoleMessage:    (evt) -> console.log(evt)
#  webviewContentLoad:       (evt) -> @get('controller').send('contentLoaded', evt)
#  webviewClose:             (evt) -> console.log(evt)
#  webviewExit:              (evt) -> console.log(evt)
#  webviewFindUpdate:        (evt) -> console.log(evt)
#  webviewLoadAbort:         (evt) -> console.log(evt)
  webviewLoadCommit:        (evt) -> @get('controller').send('loadCommit', evt)
  webviewLoadRedirect:      (evt) -> @get('controller').send('loadRedirect', evt)
  webviewLoadStart:         (evt) -> @get('controller').send('loadStart', evt)
  webviewLoadStop:          (evt) -> @get('controller').send('loadStop', evt)
  webviewNewWindow:         (evt) -> @get('controller').send('newWindow', evt)
#  webviewPermissionRequest: (evt) -> console.log(evt)
#  webviewResponsive:        (evt) -> console.log(evt)
#  webviewSizeChanged:       (evt) -> console.log(evt)
#  webviewUnresponsive:      (evt) -> console.log(evt)
#  webviewZoomChanged:       (evt) -> console.log(evt)
