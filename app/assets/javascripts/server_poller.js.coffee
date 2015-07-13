class @ServerPoller
  constructor: ->
    @poll_url = $('body').data().pollServerUrl
    @timeout_id = 0
  poll: ->
    if @poll_url
      @clear_poller()
      window.server_poller = setTimeout (=> @request()), 3000
  request: ->
    $.get(@poll_url)
  clear_poller: ->
    clearTimeout(window.server_poller)

$(document).ready(=> new ServerPoller().poll())

