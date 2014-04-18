Twingl.TreeController = Ember.Controller.extend
  needs: ['navigation']

  actions:
    newRoot: (url) ->
      console.log "Creating new root node: #{url}"

    newChild: (url) ->
      console.log "Creating child node: #{url}"

    advance: (url) ->
      # check if url is a direct descendent - create new if not, otherwise move to child
      console.log "Advancing to new node: #{url}"

    historyPop: ->
      console.log "Pop - moving back one node"

    historyPush: ->
      console.log "Push - moving forward one node"
