McFly       = require 'mcfly'
Flux        = new McFly()

AssignmentActions = Flux.createActions
  addAssignment: (course_id, user_id, article_title, language, project, role) ->
    { actionType: 'ADD_ASSIGNMENT', data: {
      user_id: user_id
      article_title: article_title
      language: language
      project: project
      role: role
    }}
  deleteAssignment: (assignment) ->
    { actionType: 'DELETE_ASSIGNMENT', data: {
      model: assignment
    }}

module.exports = AssignmentActions
