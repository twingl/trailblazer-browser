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
    @set "currentViewCenter", [ 0, 0 ]
    @set "currentViewScale", 0.2

  currentNodeId: undefined
  currentNode: ->
    @get("historyMap")[@get("currentNodeId")]

  parentNode: ->
    @get("historyMap")[@currentNode().parent_id]

  currentViewCenter: [ 0, 0 ]
  currentViewScale: 0.2

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
                       .friction 0.8
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
          setTimeout ( => @get('navigation').send('browserShow')), 40
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
      @get("historyMap")[node.id].x = @get("historyMap")[@get("currentNodeId")].x
      @get("historyMap")[node.id].y = @get("historyMap")[@get("currentNodeId")].y
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
      node.x = 50 unless node.x
      node.y = 50 unless node.y
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

    container = svg.append("g")

    zoom  = d3.behavior.zoom()
              .scaleExtent([0.2, 2])
              .on "zoom", =>
                @set('currentViewCenter', [
                  (window.innerWidth/2)  - d3.event.translate[0],
                  (window.innerHeight/2) - d3.event.translate[1] - 64
                ])
                @set('currentViewScale', d3.event.scale)
                container.transition()
                         .duration(100)
                         .ease(d3.ease("cubic-out"))
                         .attr("transform", "translate(#{d3.event.translate})scale(#{d3.event.scale})")


    svg.call(zoom)
    force.nodes(nodes)
         .links(links)
         .start()

    link = container.selectAll(".link")
              .data(links)
              .enter().append("line")
                      .attr("class", "link")

    node = container.selectAll('g.node')
              .data( nodes, (d) -> d.id )
              .enter().append("g")
                      .attr("class", (d) =>
                        "node " +
                        "#{if !d.arrived_at then "unread"} " +
                        "#{if d.id is @get('currentNodeId') then "current"} "
                      )

    pan = (duration = 300) =>
      # 64 is a magic number - same height as the browser chrome.
      zoom.translate([
        (window.innerWidth/2)  - @get('currentViewCenter')[0],
        (window.innerHeight/2) - @get('currentViewCenter')[1] - 64
      ])
      zoom.scale(@get('currentViewScale'))
      container.transition()
               .duration(duration)
               .ease(d3.ease("cubic-out"))
               .attr("transform", "translate(#{[
                 (window.innerWidth/2)  - @get('currentViewCenter')[0],
                 (window.innerHeight/2) - @get('currentViewCenter')[1] - 64
               ]})scale(#{@get('currentViewScale')})")

    pan(0)
    window.onresize = _.debounce ( => pan(0) ), 20

    #Centering on the current node
    #for n in nodes
    #  if n.id is @get('currentNodeId')
    #    window.setTimeout ( =>
    #      container.attr("transform", "translate(#{[
    #        (window.innerWidth/2) - n.x,
    #        (window.innerHeight/2) - n.y - 64
    #      ]})scale(1)")
    #    ), 2000


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
    force.on "tick", =>
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

    force.on "end", =>
      o = {}
      _.each nodes, (n) =>
        @get('historyMap')[n.id].x = n.x
        @get('historyMap')[n.id].y = n.y
        o[n.id] = { x: n.x, y: n.y }
      Ember.$.ajax "#{window.ENV['api_base']}/assignments/#{@get('assignment').id}/nodes/coords",
        method: "PUT"
        contentType: "application/json"
        data: JSON.stringify({ nodes: o })
