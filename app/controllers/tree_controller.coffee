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

  d3data:
    nodes:
      size : 25
    svg     : undefined
    force   : d3.layout.force()
                       .size [100, 100]
                       .charge -1600
                       .chargeDistance 1600
                       .linkDistance 200
                       .linkStrength 1
                       .friction 0.95
                       .gravity 0

  updateCurrentNode: (node) ->
    @set "currentNodeId", node.id
    id  = @get('assignment').get('id')
    Ember.$.ajax "#{window.ENV['api_base']}/assignments/#{id}",
      method: "PUT"
      data:
        assignment: { current_node_id: node.id }

    unless node.visited_at
      Ember.$.ajax url = "#{window.ENV['api_base']}/nodes/#{node.id}",
        method: "PUT"
        data:
          node: { arrived_at: (new Date()).toISOString() }
  ###
  # A sample node structure
  #
  # {
  #   id: ID, (assigned a temporary ID before the persisted ID is known)
  #   parent_id: ID, the parent node
  #   user_id: ID, assigned by the server
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
        parent_id:  @get('currentNodeId')
        arrived_at: (new Date()).toISOString()
        idle:       false

      Ember.$.post url, {node: node}, (response) =>
        node.id = response.id
        @get("historyMap")[node.id] = node
        delete @get("historyMap")[temporaryId]

        @updateCurrentNode(node)

      @get("historyStack").push(node)
      @get("historyMap")[node.id] = node
      console.log @get('historyStack'), @get('historyMap')

    queueUnread: (node) ->
      id  = @get('assignment').get('id')
      url = "#{window.ENV['api_base']}/assignments/#{id}/nodes"
      temporaryId = @generateTemporaryId()

      node = Ember.$.extend node,
        id:         temporaryId
        parent_id: @get('currentNodeId')
        idle:       false

      Ember.$.post url, {node: node}, (response) =>
        node.id = response.id
        @get("historyMap")[node.id] = node
        delete @get("historyMap")[temporaryId]

        # If the title isn't present, request it from the API
        if !node.title
          w = document.createElement("webview")
          w.src = node.url
          w.addEventListener "contentload", (evt) =>
            console.log "contentload", evt
            w.executeScript code: "document.title", (r) =>
              document.body.removeChild(w)
              @get("historyMap")[node.id].title = r[0]
              Ember.$.ajax "#{window.ENV['api_base']}/nodes/#{node.id}",
                method: "PUT"
                data:
                  node: { title: r[0] }
          document.body.appendChild(w)

      @get("historyStack").push(node)
      @get("historyMap")[node.id] = node

    ###
    # Rendering the graph
    ###
    drawTree: ->
      Ember.$("#tb-history-tree-viz").html('')
      @get("d3data").svg = d3.select('#tb-history-tree-viz').append('svg')

      if @get("historyStack").length > 0
        @update()
        svgPanZoom("#tb-history-tree-viz>svg",
          zoomScaleSensitivity: 0.2
          minZoom:              0.005
          maxZoom:              0.2)
        .zoomAtPoint(0.2, x: 0, y: 0)


  update: ->
    map = @get("historyMap")
    history = $.extend true, {}, map
    console.log history

    # Initialize our in-memory data structures for the D3 canvas
    links = []
    nodes = []
    idMap = {}
    index = 0

    # Generate lists of nodes, links and a mapping from ID to list index
    for id, node of history
      idMap[node.id] = index++
      node.offsets =
        x: @get('d3data').nodes.size * 2
        y:
          minor: @get('d3data').nodes.size * 1.1
          major: @get('d3data').nodes.size * 2.3
      if node.parent_id
        links.push(source: idMap[node.parent_id], target: idMap[node.id])
      else
        node.x = 50
        node.y = 50
        node.fixed = true
      nodes.push node


    force = @get('d3data').force
    svg   = @get('d3data').svg

    force.nodes(nodes)
         .links(links)
         .start()

    link = svg.selectAll(".link")
              .data(links)
              .enter().append("line")
                      .attr("class", "link")

    node = svg.selectAll('g.node')
              .data( nodes, (d) -> d.id )
              .enter().append("g")
                      .attr("class", (d) =>
                        "node " +
                        "#{if !d.arrived_at then "unread"} " +
                        "#{if d.id is @get('currentNodeId') then "current"} "
                      )

    node.on "click", (d) =>
      @updateCurrentNode(d)
      @get('webview').navigate d.url, false

    poly = node.append("polygon")
               .attr("stroke-linejoin", "round")

    label = node.append("foreignObject")
                .attr("requiredFeatures", "http://www.w3.org/TR/SVG11/feature#Extensibility")
                .attr("x", 0)
                .attr("y", 0)
                .attr("width",  @get('d3data').nodes.size * 4)
                .attr("height", @get('d3data').nodes.size * 2.2)

    label.append("xhtml:body")
           .append("p")
           .text((d) -> d.title)

    # Update the position of the nodes and links
    force.on "tick", ->
      link.attr("x1", (d) -> d.source.x)
          .attr("y1", (d) -> d.source.y)
          .attr("x2", (d) -> d.target.x)
          .attr("y2", (d) -> d.target.y)

      poly.attr("points", (d) ->
                "#{d.x+d.offsets.x},#{d.y+d.offsets.y.minor} " +
                "#{d.x+d.offsets.x},#{d.y-d.offsets.y.minor} " +
                "#{d.x            },#{d.y-d.offsets.y.major} " +
                "#{d.x-d.offsets.x},#{d.y-d.offsets.y.minor} " +
                "#{d.x-d.offsets.x},#{d.y+d.offsets.y.minor} " +
                "#{d.x            },#{d.y+d.offsets.y.major} " )

      label.attr("x", (d) -> d.x-d.offsets.x)
           .attr("y", (d) -> d.y-d.offsets.y.minor)
