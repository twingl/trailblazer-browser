Twingl = Ember.Application.create()

view = Ember.View.create
  templateName: 'test/world'
  message: "World!"

view.appendTo('body')
