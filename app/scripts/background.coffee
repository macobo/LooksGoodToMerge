'use strict'

RETRY_INTERVAL = 3000

notifications =
  passed: (summary) ->
    title: "##{summary.id}: #{summary.title}"
    options:
      icon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACQAAAAkCAYAAADhAJiYAAACAElEQVR42u2XTUsbQRzGf4kxinj3UERBERUPCp7mvAcvHvwQXnRs1VZa3/AlFhUR36YU9Fv0PCcPe+slpSCEHkpbij30rEk0Xv6BEHaNMdmMhzywLMzsLr+Z+b88C001VZtiYRPa99qAZWABiAOnQMooe9NwIIH5Abwqm7oGeqOEioeMvxOYHSAh1ybQBaxHuUNhQHNy3zbK3hll7wQO4LULoKyroA4DOpN7SvteQvteixwZwKELoGMJ6vdADsgDa8AvYLfhQEbZHDAYMJU2yt46qUOS/oWA4W6j7O9GH9lj+qJ9L/aSgMaAg5cEBPBW+95eFDv1nBgq1SUwZZT9H/BuAtBSSDsAAxxUSopqgT4BswGPXkjzzUhRjQNpYLjaXljtkc2VtJVSTQPfgBvgXqCGpZ61Aa3AlvTC1brFkFG2YJQ1wListtJ3Pxhls0bZPJCSsfm6B7VR9qu4gRmp4nVT4rkvigP4rH3vHBgFJoEJYAjolMXuad9bAgrSeoptqT5BbZR9UppLhn0HBqIO6qfuXh4YEaP3E/gHbAA9ldxmrMIqc2XD7VE313gITCtwFTCV0b6XdOGHFoE+YB9IyrUDdAMrLoCK1XjdKJsTf1R0jG9cACWjKBW1AJ084qmPXAAdin8u99R/gI8uPHUW6Jdf6b9S0NaAvqjTvqmmatUD31ijYHqXLVUAAAAASUVORK5CYII="
      body: "Tests passed."
  failed: (summary) ->
    title: "##{summary.id}: #{summary.title}"
    options:
      body: "Tests failed. Click to open the pull request."
  merged: (summary) ->
    title: "##{summary.id}: #{summary.title}"
    options:
      body: "Pull request has been merged."
  closed: (summary) ->
    title: "##{summary.id}: #{summary.title}"
    options:
      body: "Pull request has been closed."
  unknown: (summary) ->
    title: "Error in script"
    options:
      body: "Could not merge ##{summary.id}: #{summary.title} - unknown error."

showTimedNotification = (title, options, onClickUrl, timeout) ->
  if !Notification.permission isnt 'granted'
    Notification.requestPermission()

  notification = new Notification(title, options)
  notification.onshow = ->
    if (timeout > 0)
      setTimeout(notification.close.bind(notification), timeout)
  notification.onclick = ->
    if (onClickUrl)
      window.open(onClickUrl)

markWorkDone = (summary) ->
  console.log "Marking PR as done:", summary
  {title, options} = notifications[summary.status](summary)
  showTimedNotification title, options, summary.url, 10000

checkPassed = (summary) ->
  {status, url} = summary
  requeue = ->
    setTimeout((-> checkPassed(summary)), RETRY_INTERVAL)

  $.get(url, (data) ->
    # See http://stackoverflow.com/questions/14667441/jquery-unrecognized-expression-on-ajax-response
    $dom = $($.parseHTML(data))
    newSummary = github.pullRequest.summary(url, $dom)

    if (newSummary.status != 'pending')
      console.log "Update!", newSummary
      markWorkDone newSummary
    else
      console.log "No updates, retrying in #{RETRY_INTERVAL/1000.0}s.", url, summary
      requeue()
  ).fail requeue

chrome.extension.onMessage.addListener (request) ->
  console.log 'Received message', request
  switch request.type
    when 'merge-pending-when-passed' then checkPassed(request.summary)
