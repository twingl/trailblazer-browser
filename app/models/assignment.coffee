Twingl.Assignment = DS.Model.extend
  title: DS.attr('string')
  description: DS.attr('string')
  started_at: DS.attr('date')
  completed_at: DS.attr('date')
  current_node_id: DS.attr('number')
  project_id: DS.attr('number')
