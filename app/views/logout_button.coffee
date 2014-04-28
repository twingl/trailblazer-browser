Twingl.LogoutButton = Ember.Component.extend
  tagName   : 'button'
  classNames: [ 't-auth-logout', 't-nav-button' ]
  action    : "invalidateSession"
  layoutName: "button"
  text      : "Logout"

  click: ->
    @sendAction()
