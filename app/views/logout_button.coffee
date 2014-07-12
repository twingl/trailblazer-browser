Twingl.LogoutButton = Ember.Component.extend
  tagName   : "i"
  classNames: [ "tb-auth-logout", "tb-nav-button", "fa", "fa-sign-out" ]
  action    : "invalidateSession"

  click: ->
    @sendAction()
