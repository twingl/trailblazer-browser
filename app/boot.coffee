###
# Configure SimpleAuth
###
window.ENV ||= {}

window.ENV['default_page'] = "http://google.com"
window.ENV['search_page'] = "http://google.com"

window.ENV['api_host'] = "https://app.trailblazer.io"
window.ENV['api_namespace'] = "api/v1"

window.ENV['api_base'] = "#{window.ENV['api_host']}/#{window.ENV['api_namespace']}"

window.ENV['simple-auth'] =
  store:      'simple-auth-session-store:ephemeral'
  authorizer: 'simple-auth-authorizer:oauth2-bearer'
  crossOriginWhitelist: [ window.ENV['api_host'] ]


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
