Twingl.BrowserRoute = Ember.Route.extend SimpleAuth.AuthenticatedRouteMixin,
  model: ->
    # Retrieve the assignment history (nodes) from the server and return the
    # promise to be handled by Ember
    id = @controllerFor('application').get('assignment').id
    url = "#{window.ENV['api_base']}/assignments/#{id}/nodes"
    Ember.$.getJSON url

  setupController: (controller, model) ->
    controller = @controllerFor('tree')

    if model.nodes.length > 0
      # Insert the retrieved nodes into the history stack and map
      for node in model.nodes
        controller.get('historyStack').push node
        controller.get('historyMap')[node.id] = node

      # If we have a known currentNodeId, set the currentNodeId on the
      # controller iff this node is present in the history map, otherwise set
      # it to the most recently viewed node
      currentNodeId = controller.get('assignment').get('current_node_id')
      if currentNodeId and controller.get('historyMap').hasOwnProperty(currentNodeId)
        controller.set 'currentNodeId', controller.get('assignment').get('current_node_id')
      else
        controller.set 'currentNodeId', controller.get('historyStack').filterBy("arrived_at")[0].id

      # Navigation elements fail to hide/show if run without a slight delay
      setTimeout ( => controller.get('navigation').send('historyShow')), 40

      # Load the current node's URL in the webview
      controller.get('webview').navigate controller.currentNode().url, false
    else
      # we have an empty project - send us to the home page
      setTimeout ( => controller.get('navigation').send('browserShow')), 40
      controller.get('webview').navigate(window.ENV['default_page'])

  renderTemplate: ->
    @render 'main/webview',
      outlet: 'main'
      controller: 'webview'

    @render 'navigation/browser',
      outlet: 'navigation'
      controller: 'navigation'

    @render 'alt/tree',
      outlet: 'alt'
      controller: 'tree'

    @render 'windowNavigation/projects',
      outlet: 'windowNavigation'
      controller: 'application'
