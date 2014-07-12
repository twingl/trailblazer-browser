Twingl.LogoutButton = Ember.Component.extend
  tagName   : 'button'
  classNames: [ 'tb-auth-logout', 'tb-nav-button' ]
  action    : "invalidateSession"
  layoutName: "button"
  text      : "Logout"

  click: ->
    @sendAction()
