Twingl.HistoryShowButton = Ember.Component.extend
  tagName   : "i"
  classNames: [ "tb-history-show", "tb-nav-button", "fa", "fa-share-alt" ]
  action    : "historyShow"

  click: ->
    @sendAction()
