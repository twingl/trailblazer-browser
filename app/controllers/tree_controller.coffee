# Responsible for the Trail.
#
# Receives commands from the webview controller and mutates the tree based on
# those. Commands received from the webview are additive - they do not remove
# parts of the tree.
#
# Responsible for structuring the data such that it can be persisted on the API
# and rendered in the browser.
Twingl.TreeController = Ember.Controller.extend
  needs: ['application', 'navigation', 'webview']
  application: Ember.computed.alias "controllers.application"
  navigation: Ember.computed.alias "controllers.navigation"
  webview: Ember.computed.alias "controllers.webview"

  assignment: Ember.computed.alias "controllers.application.assignment"

  # Temporary IDs, i.e. those that are client-assigned before a response is
  # received from the server, are of the form TB.tmp.<random token>
  historyStack: []
  historyMap:   {}

  resetState: ->
    @set "currentNodeId", undefined
    @set "historyStack",  []
    @set "historyMap",    {}

  currentNodeId: undefined
  currentNode: ->
    @get("historyMap")[@get("currentNodeId")]

  ###
  # A sample node structure
  #
  # {
  #   id: ID, (assigned a temporary ID before the persisted ID is known)
  #   url: String,
  #   title: String,
  #   arrived_at: Date,
  #   departed_at: Date,
  #   idle: Boolean
  # }
  #
  ###
  generateTemporaryId: ->
    "TB.tmp." + Math.random().toString(36).substr(2, 9)

  actions:
    loadHistory: (cb) ->
      id  = @get('assignment').get('id')
      url = "#{window.ENV['api_base']}/assignments/#{id}/nodes"

      Ember.$.get url, (response) =>
        if response.nodes.length > 0
          # open the trail view
          # TODO set the current page to [current_node_id]
          for node in response.nodes
            @get('historyStack').push node
            @get('historyMap')[node.id] = node

          currentNodeId = @get('assignment').get('current_node_id')
          if currentNodeId and @get('historyMap').hasOwnProperty(currentNodeId)
            @set 'currentNodeId', @get('assignment').get('current_node_id')
          else
            @set 'currentNodeId', @get('historyStack').filterBy("arrived_at")[0].id

          # Navigation elements fail to hide/show if run without a slight delay
          setTimeout ( => @get('navigation').send('historyShow')), 40

          @get('webview').navigate @currentNode().url, false
        else
          # we have an empty project - send us to the home page
          @get('webview').navigate(window.ENV['default_page'])
        console.log @get('historyStack'), @get('historyMap')
        cb()

    pushItem: (node) ->
      id  = @get('assignment').get('id')
      url = "#{window.ENV['api_base']}/assignments/#{id}/nodes"
      temporaryId = @generateTemporaryId()

      node = Ember.$.extend node,
        id:         temporaryId
        arrived_at: (new Date()).toISOString()
        idle:       false

      Ember.$.post url, {node: node}, (response) =>
        node.id = response.id
        @get("historyMap")[node.id] = node
        delete @get("historyMap")[temporaryId]

      @get("historyStack").push(node)
      @get("historyMap")[node.id] = node
      console.log @get('historyStack'), @get('historyMap')

    queueUnread: (node) ->
      id  = @get('assignment').get('id')
      url = "#{window.ENV['api_base']}/assignments/#{id}/nodes"
      temporaryId = @generateTemporaryId()

      node = Ember.$.extend node,
        id:         temporaryId
        idle:       false

      Ember.$.post url, {node: node}, (response) =>
        node.id = response.id
        @get("historyMap")[node.id] = node
        delete @get("historyMap")[temporaryId]

      @get("historyStack").push(node)
      @get("historyMap")[node.id] = node
      console.log @get('historyStack'), @get('historyMap')
