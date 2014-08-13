Twingl.BrowserController = Ember.Controller.extend
  # The single source of truth for browsing history and the trail.
  # This map contains all nodes in the trail, addressed by either their
  # server-returned ID or a temporary ID generated during the creation process
  # (which is short lived, and to be replaced by the server's ID)
  history: new Ember.Map()

  # Computed properties to make accessing model details simpler
  assignment: Ember.computed.alias('model')

  # Fetches the history from the back end and loads it into the application.
  # Sets up the history map, and restores the current node to the browser
  # itself.
  restoreHistory: ( ->
    url = "#{window.ENV['api_base']}/assignments/#{@get('assignment.id')}/nodes"
    Ember.$.getJSON url, (response) =>
      @set('history', new Ember.Map())
      @get('history').set(node.id, node) for node in response.nodes
      console.log @get('currentNode'), @get('currentNode.id')

      #TODO We have the currentNode and history loaded, let's move on to the view refactor
  ).observes('model.id')

  # Details about the current node, i.e. where in the trail we are currently
  # located. Derived from the `current_node_id` field stored on the assignment
  # model.
  currentNode: ( ->
    @get('history').get @get('assignment.current_node_id')
  ).property('assignment.current_node_id')

  # A computed property which represents the `history` map as a stack ordered by
  # the arrival time on a node.
  # FIXME the stack is ordered 0 being the oldest entry, so it is addressed in
  # reverse meaning push/pop() operations won't function as expected (although
  # they shouldn't need be used anyway - the primary interface is the map)
  historyStack: ( ->
    values = []
    @get('history').forEach (k,v) -> values.push(v)
    values.sortBy('arrived_at')
  ).property('history')
