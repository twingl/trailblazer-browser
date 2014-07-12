Twingl.HistoryBackButton = Ember.Component.extend
  tagName   : 'button'
  classNames: [ 'tb-history-back', 'tb-nav-button' ]
  action    : "navigateHistoryBack"
  layoutName: "button"
  text      : "Back"

  click: ->
    @sendAction()
