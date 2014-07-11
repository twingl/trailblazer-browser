###
# Configure SimpleAuth
###
window.ENV ||= {}
window.ENV['simple-auth'] =
  store:      'simple-auth-session-store:ephemeral'
  authorizer: 'simple-auth-authorizer:oauth2-bearer'
  crossOriginWhitelist: ['http://localhost:3000']


window.Twingl = Ember.Application.create
  rootElement: "#app"

  ready: ->
    document.title = "Twingl Browser"

  # Register the events emitted by the <webview> element
  customEvents:
    close             : "webviewClose"
    consolemessage    : "webviewConsoleMessage"
    contentload       : "webviewContentLoad"
    dialog            : "webviewClose"
    exit              : "webviewExit"
    findupdate        : "webviewFindUpdate"
    loadabort         : "webviewLoadAbort"
    loadcommit        : "webviewLoadCommit"
    loadredirect      : "webviewLoadRedirect"
    loadstart         : "webviewLoadStart"
    loadstop          : "webviewLoadStop"
    newwindow         : "webviewNewWindow"
    permissionrequest : "webviewPermissionRequest"
    responsive        : "webviewResponsive"
    sizechanged       : "webviewSizeChanged"
    unresponsive      : "webviewUnresponsive"
    zoomchange        : "webviewZoomChanged"

Twingl.views ||= {}
