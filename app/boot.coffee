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
