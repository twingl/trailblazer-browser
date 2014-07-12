Twingl.HistoryShowButton = Ember.Component.extend
  tagName   : 'button'
  classNames: [ 'tb-history-show', 'tb-nav-button' ]
  action    : "historyShow"
  layoutName: "button"
  text      : "History"

  click: ->
    @sendAction()
