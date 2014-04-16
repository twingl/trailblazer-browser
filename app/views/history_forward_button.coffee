Twingl.HistoryForwardButton = Ember.Component.extend
  tagName     : 'button'
  classNames  : [ 't-history-forward', 't-nav-button' ]
  action      : "navigateHistoryForward"
  templateName: "button"
  text        : "Forward"

  click: ->
    @sendAction()
