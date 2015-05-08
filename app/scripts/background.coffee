'use strict'

RETRY_INTERVAL = 3000

testsPassedOptions = ->
  title: "Tests passed"
  options:
    icon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACQAAAAkCAYAAADhAJiYAAACAElEQVR42u2XTUsbQRzGf4kxinj3UERBERUPCp7mvAcvHvwQXnRs1VZa3/AlFhUR36YU9Fv0PCcPe+slpSCEHkpbij30rEk0Xv6BEHaNMdmMhzywLMzsLr+Z+b88C001VZtiYRPa99qAZWABiAOnQMooe9NwIIH5Abwqm7oGeqOEioeMvxOYHSAh1ybQBaxHuUNhQHNy3zbK3hll7wQO4LULoKyroA4DOpN7SvteQvteixwZwKELoGMJ6vdADsgDa8AvYLfhQEbZHDAYMJU2yt46qUOS/oWA4W6j7O9GH9lj+qJ9L/aSgMaAg5cEBPBW+95eFDv1nBgq1SUwZZT9H/BuAtBSSDsAAxxUSopqgT4BswGPXkjzzUhRjQNpYLjaXljtkc2VtJVSTQPfgBvgXqCGpZ61Aa3AlvTC1brFkFG2YJQ1wListtJ3Pxhls0bZPJCSsfm6B7VR9qu4gRmp4nVT4rkvigP4rH3vHBgFJoEJYAjolMXuad9bAgrSeoptqT5BbZR9UppLhn0HBqIO6qfuXh4YEaP3E/gHbAA9ldxmrMIqc2XD7VE313gITCtwFTCV0b6XdOGHFoE+YB9IyrUDdAMrLoCK1XjdKJsTf1R0jG9cACWjKBW1AJ084qmPXAAdin8u99R/gI8uPHUW6Jdf6b9S0NaAvqjTvqmmatUD31ijYHqXLVUAAAAASUVORK5CYII="
    body: "#4545 Backfill tests"

showTimedNotification = (title, status, onClickUrl, timeout) ->
  if !Notification.permission isnt 'granted'
    Notification.requestPermission()

  notification = new Notification(title, status)
  notification.onshow = ->
    if (timeout > 0)
      setTimeout(notification.close.bind(notification), timeout)
  notification.onclick = ->
    if (onClickUrl)
      window.open(onClickUrl)

show = (status, url) ->
  {title, options} = switch status
    when "passed" then testsPassedOptions()
  showTimedNotification(title, options, url, 10000)

checkPassed = (startState, url) ->
  console.debug "checking on #{url} (start state: #{startState})"
  requeue = ->
    setTimeout((-> checkPassed(startState, url)), RETRY_INTERVAL)


  $.get(url, (data) ->
    # See http://stackoverflow.com/questions/14667441/jquery-unrecognized-expression-on-ajax-response
    $dom = $($.parseHTML(data))
    window.$dom = $dom
    newStatus = github.extractPullStatus($dom)

    if (newStatus != startState || newStatus == 'passed')
      show(newStatus, url)
    else
      console.log("No updates, retrying in #{RETRY_INTERVAL/1000.0}s.", url)
      requeue()

  ).fail requeue

chrome.extension.onMessage.addListener (request) ->
  console.log 'Received message', request
  switch request.type
    when 'notify-passed' then checkPassed(request.state, request.url)
