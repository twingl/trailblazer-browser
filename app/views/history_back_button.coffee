Twingl.HistoryBackButton = Ember.Component.extend
  tagName     : 'button'
  classNames  : [ 't-history-back', 't-nav-button' ]
  action      : "navigateHistoryBack"
  templateName: "button"
  text        : "Back"

  click: ->
    @sendAction()
