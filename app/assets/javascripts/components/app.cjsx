React         = require 'react'
ReactRouter   = require 'react-router'
Router        = ReactRouter.Router
Notifications = require './common/notifications'

App = React.createClass(
  displayName: 'App'
  componentDidMount: ->
    setInterval(->
      $.ajax
        type: 'GET'
        url: '/auth-check'
        success: (data) ->
          if data.oauth_valid is false
            window.location = '/sign_out'
    , 30 * 1000)
  render: ->
    <div>
      <Notifications />
      {@props.children}
    </div>
)

module.exports = App
