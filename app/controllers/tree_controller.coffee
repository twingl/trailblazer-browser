Twingl.TreeController = Ember.Controller.extend
  needs: ['navigation']

  currentNode: {}

  historyStack: []

  currentNodeId: 0

  ###
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
  ###

  cOb: `function() {
    console.log("this.currentNode: ", this.get('currentNode'))
  }.observes('currentNode')`

  hOb: `function() {
    console.log("this.historyTree: ", this.get('historyTree'))
  }.observes('historyTree')`

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

    nodeEnter.append("circle")
              .attr("r", "4px")
              .style("fill", "red")

    nodeEnter.append("text")
              .attr("x", -10)
              .attr("dy", ".35em")
              .attr("text-anchor", "end")
              .text( (d) -> d.url )

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

    newRoot: (url) ->
      node =
        id        : ++@currentNodeId
        root      : true
        parent    : undefined
        children  : []
        visited   : [ { start: Date.now(), finish: undefined, idle: false } ]
        url       : url
        created_at: Date.now()

      if !@get('historyTree')
        @set('historyTree', node)
        @set('currentNode', node)
        console.log "New Root! #{url}"
      else
        node.parent = @get('currentNode')
        @get('currentNode').children ||= []
        @get('currentNode').children.push node
        @set('currentNode', node)
        console.log "Creating new pseudo-root node: #{url}"

    newChild: (url) ->
      @get('currentNode').children ||= []
      if @get('currentNode').children.filterBy('url', url).length is 0
        node =
          id        : ++@currentNodeId
          root      : false
          parent    : @get('currentNode')
          children  : []
          visited   : []
          url       : url
          created_at: Date.now()

        @get('currentNode').children.push(node)
        console.log "Creating child node: #{url}"
      else
        console.log "Child node exists: #{url}"

    advance: (url) ->
      # check if url is a direct descendent - create new if not, otherwise move to child
      @get('currentNode').children ||= []
      if @get('currentNode').children.filterBy('url', url).length is 0
        node =
          id        : ++@currentNodeId
          root      : false
          parent    : @get('currentNode')
          children  : []
          visited   : [ { start: Date.now(), finish: undefined, idle: false } ]
          url       : url
          created_at: Date.now()

        @get('currentNode').children ||= []
        @get('currentNode').children.push(node)
        @set('currentNode', node)
        console.log "Advancing to new node: #{url}"
      else
        node = @get('currentNode').children.filterBy('url', url).pop()
        node.visited.push { start: Date.now(), finish: undefined, idle: false }
        @set('currentNode', node)
        console.log "Advancing to existing node: #{url}"

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
