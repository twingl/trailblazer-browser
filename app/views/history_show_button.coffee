Twingl.HistoryShowButton = Ember.Component.extend
  tagName   : 'button'
  classNames: [ 't-history-show', 't-nav-button' ]
  action    : "historyShow"
  layoutName: "button"
  text      : "History"

  click: ->
    @sendAction()
