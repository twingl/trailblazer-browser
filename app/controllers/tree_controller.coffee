# Responsible for the Trail interface.
#
# This controller stores the history tree in memory, and is responsible for
# rendering it using D3 and handling interface events invoked from within the
# trail view.
#
# This controller is very much a work in progress
#
# NOTE: `visited` log is not currently implemented fully
Twingl.TreeController = Ember.Controller.extend
  needs: ['navigation']
  navigation: Ember.computed.alias "controllers.navigation"

  resetState: ->
    @set 'currentNode',   {}
    @set 'historyStack',  []
    @set 'curretnNodeId', 0

  currentNode: {}

  historyStack: []

  currentNodeId: 0

  ###
  # A sample node structure
  #
  # {
  #   id: ID,
  #   root: Boolean, //Indicates if the item is a root item or direct child
  #   parent: ID,
  #   children: [ ... ],
  #   visited: [
  #     {
  #       start: Date,
  #       finish: Date,
  #       idle: Boolean
  #     },
  #     ...
  #   ],
  #   url: String,
  #   created_at: Date
  # }
  # {
  #   id: ID,
  #   url: String,
  #   title: String,
  #   arrived_at: Date,
  #   departed_at: Date,
  #   idle: Boolean
  # }
  ###

  historyTree: undefined

  d3data:
    svg     : undefined
    height  : 800
    width   : 600
    tree    : d3.layout.tree().size( [800, 600] )
    diagonal: d3.svg.diagonal().projection((d) -> [d.y, d.x])

  update: () ->
    nodes = @get('d3data').tree.nodes(@get('historyTree')).reverse()
    links = @get('d3data').tree.links(nodes)

    node = @get('d3data').svg.selectAll('g.node').data( nodes, (d) -> d.id )

    nodeEnter = node.enter()
             .append("g")
              .attr("class", "node")
              .attr("transform", (d) -> "translate(#{d.y}, #{d.x})")
              .on "click", (d) =>
                @set 'currentNode', d
                @get('navigation').send('navigateNode', d.url)

    nodeEnter.append("circle")
              .attr("r", "4px")
              .style("fill", "red")

    nodeEnter.append("text")
              .attr("x", -10)
              .attr("dy", ".35em")
              .attr("text-anchor", "end")
              .text( (d) -> d.title )

    link = @get('d3data').svg.selectAll("path.link").data( links, (d) -> d.target.id )

    link.enter().insert("path", "g")
                  .attr("class", "link")
                  .attr("d", @get('d3data').diagonal)



  actions:
    drawTree: ->
      document.getElementById('t-history-tree-viz').innerHTML = ''
      @get('d3data').svg = d3.select('#t-history-tree-viz')
                    .append('svg')

      if @get('historyTree')
        @update()
        svgPanZoom.init({ 'selector': '#t-history-tree-viz>svg' })

    newRoot: (obj) ->
      node =
        id        : ++@currentNodeId
        root      : true
        parent    : undefined
        children  : []
        visited   : [ { start: Date.now(), finish: undefined, idle: false } ]
        url       : obj.url
        title     : obj.title
        created_at: Date.now()

      if !@get('historyTree')
        @set('historyTree', node)
        @set('currentNode', node)
        console.log "New Root! #{obj.url}"
      else
        node.parent = @get('currentNode')
        @get('currentNode').children ||= []
        @get('currentNode').children.push node
        @set('currentNode', node)
        console.log "Creating new pseudo-root node: #{obj.url}"

    newChild: (obj) ->
      @get('currentNode').children ||= []
      if @get('currentNode').children.filterBy('url', obj.url).length is 0
        node =
          id        : ++@currentNodeId
          root      : false
          parent    : @get('currentNode')
          children  : []
          visited   : []
          url       : obj.url
          title     : obj.title
          created_at: Date.now()

        @get('currentNode').children.push(node)
        console.log "Creating child node: #{obj.url}"
      else
        console.log "Child node exists: #{obj.url}"

    advance: (obj) ->
      # check if url is a direct descendent - create new if not, otherwise move to child
      @get('currentNode').children ||= []
      if @get('currentNode').children.filterBy('url', obj.url).length is 0
        node =
          id        : ++@currentNodeId
          root      : false
          parent    : @get('currentNode')
          children  : []
          visited   : [ { start: Date.now(), finish: undefined, idle: false } ]
          url       : obj.url
          title     : obj.title
          created_at: Date.now()

        @get('currentNode').children ||= []
        @get('currentNode').children.push(node)
        @set('currentNode', node)
        console.log "Advancing to new node: #{obj.url}"
      else
        node = @get('currentNode').children.filterBy('url', obj.url).pop()
        node.visited.push { start: Date.now(), finish: undefined, idle: false }
        @set('currentNode', node)
        console.log "Advancing to existing node: #{obj.url}"

    historyPop: ->
      p = @get('historyStack').pop()
      if p
        @set('currentNode', p)
        console.log "Pop - moving forward one node"
      else
        console.log "ohfuck no history to go to"

    historyPush: ->
      p = @get('currentNode').parent
      if p
        @get('historyStack').push @get('currentNode')
        @set('currentNode', p)
        console.log "Push - moving back one node"
      else
        console.log "ohfuck no parent"
