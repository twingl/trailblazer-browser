Twingl.SearchButton = Ember.Component.extend
  tagName   : "i"
  classNames: [ "tb-search-show", "tb-nav-button", "fa", "fa-search" ]
  action    : "navigateSearch"

  click: ->
    @sendAction()
