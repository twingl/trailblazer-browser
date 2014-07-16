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
      color: "#ccc"
      size : 25
    svg     : undefined
    height  : 1
    width   : 1
    force   : d3.layout.force().size( [1, 1] ).charge(-800).linkDistance(200).gravity(0)
    diagonal: d3.svg.diagonal().projection((d) -> [d.y, d.x])

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
        parent_id:  @get('currentNodeId')
        arrived_at: (new Date()).toISOString()
        idle:       false

      Ember.$.post url, {node: node}, (response) =>
        node.id = response.id
        @get("historyMap")[node.id] = node
        delete @get("historyMap")[temporaryId]

        @set "currentNodeId", node.id
        url = "#{window.ENV['api_base']}/assignments/#{id}"
        Ember.$.ajax url,
          method: "PUT"
          data:
            assignment: { current_node_id: node.id }

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

      @get("historyStack").push(node)
      @get("historyMap")[node.id] = node
      console.log @get('historyStack'), @get('historyMap')

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
          minZoom:              0.005)
        .zoomAtPoint(0.5, x: 0, y: 0)


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
      nodes.push node
      if node.parent_id
        links.push(source: idMap[node.parent_id], target: idMap[node.id])


    force = @get('d3data').force
    svg   = @get('d3data').svg

    force.nodes(nodes)
         .links(links)
         .start()

    link = svg.selectAll(".link")
              .data(links)
              .enter().append("line")
                      .attr("class", "link")
                      .style("stroke-width", 4)

    node = svg.selectAll('g.node')
              .data( nodes, (d) -> d.id )
              .enter().append("g")
                      .attr("class", "node")

    poly = node.append("polygon")
               .attr("stroke-width", "20")
               .attr("stroke-linejoin", "round")
               .attr("stroke", @get("d3data").nodes.color)
               .style("fill",  @get("d3data").nodes.color)

    #label = node.append("g")
    #            .attr("requiredFeatures", "http://www.w3.org/Graphics/SVG/feature/1.2/#TextFlow")
    #            .attr("x", (d) -> d.x)
    #            .attr("y", (d) -> d.y)
    #            .attr("width", 24)
    #            .attr("height", 24)
    #            .append("textArea")
    #              .text((d) -> d.title)
    label = node.append("foreignObject")
                .attr("requiredFeatures", "http://www.w3.org/TR/SVG11/feature#Extensibility")
                #.attr("requiredExtensions", "http://www.w3.org/1999/xhtml")
                .attr("x", 0)
                .attr("y", 0)
                .attr("width",  @get('d3data').nodes.size * 4)
                .attr("height", @get('d3data').nodes.size * 2.2)
    label.append("xhtml:body")
           .append("p")
           .text((d) -> d.title)
    #label = node.append("text")
    #            .attr("x", 0)
    #            .attr("dy", "0.35em")
    #            .attr("text-anchor", "end")
    #            .text((d) -> d.title)

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

