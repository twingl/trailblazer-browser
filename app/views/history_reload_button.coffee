Twingl.HistoryReloadButton = Ember.Component.extend
  tagName   : 'button'
  classNames: [ 'tb-history-reload', 'tb-nav-button' ]
  action    : "navigateReload"
  layoutName: "components/button"
  text      : "Reload"

  click: ->
    @sendAction()
