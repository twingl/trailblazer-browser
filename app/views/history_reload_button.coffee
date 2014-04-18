Twingl.HistoryReloadButton = Ember.Component.extend
  tagName   : 'button'
  classNames: [ 't-history-reload', 't-nav-button' ]
  action    : "navigateReload"
  layoutName: "button"
  text      : "Reload"

  click: ->
    @sendAction()
