'use strict'

window.store = new TaskStore()
RETRY_INTERVAL = 3000

notifications =
  passed: (summary) ->
    title: "##{summary.id}: #{summary.title}"
    options:
      icon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACQAAAAkCAYAAADhAJiYAAACAElEQVR42u2XTUsbQRzGf4kxinj3UERBERUPCp7mvAcvHvwQXnRs1VZa3/AlFhUR36YU9Fv0PCcPe+slpSCEHkpbij30rEk0Xv6BEHaNMdmMhzywLMzsLr+Z+b88C001VZtiYRPa99qAZWABiAOnQMooe9NwIIH5Abwqm7oGeqOEioeMvxOYHSAh1ybQBaxHuUNhQHNy3zbK3hll7wQO4LULoKyroA4DOpN7SvteQvteixwZwKELoGMJ6vdADsgDa8AvYLfhQEbZHDAYMJU2yt46qUOS/oWA4W6j7O9GH9lj+qJ9L/aSgMaAg5cEBPBW+95eFDv1nBgq1SUwZZT9H/BuAtBSSDsAAxxUSopqgT4BswGPXkjzzUhRjQNpYLjaXljtkc2VtJVSTQPfgBvgXqCGpZ61Aa3AlvTC1brFkFG2YJQ1wListtJ3Pxhls0bZPJCSsfm6B7VR9qu4gRmp4nVT4rkvigP4rH3vHBgFJoEJYAjolMXuad9bAgrSeoptqT5BbZR9UppLhn0HBqIO6qfuXh4YEaP3E/gHbAA9ldxmrMIqc2XD7VE313gITCtwFTCV0b6XdOGHFoE+YB9IyrUDdAMrLoCK1XjdKJsTf1R0jG9cACWjKBW1AJ084qmPXAAdin8u99R/gI8uPHUW6Jdf6b9S0NaAvqjTvqmmatUD31ijYHqXLVUAAAAASUVORK5CYII="
      body: "Tests passed."
  failed: (summary) ->
    title: "Tests failed for ##{summary.id}"
    options:
      # color: #bd2c00
      icon: "data:image/png;base64,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"
      body: "Tests failed. Click to open the pull request."
  merged: (summary) ->
    title: "Merged ##{summary.id}"
    options:
      # color: #6e5494
      icon: "data:image/png;base64,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"
      body: "\"#{summary.title}\""
  closed: (summary) ->
    title: "##{summary.id} has been closed"
    options:
      icon: "data:image/png;base64,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"
      body: "\"#{summary.title}\""
  unknown: (summary) ->
    title: "Error"
    options:
      icon: "data:image/png;base64,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"
      body: "Could not merge ##{summary.id}: #{summary.title}."

showTimedNotification = (title, options, onClickUrl, timeout) ->
  if !Notification.permission isnt 'granted'
    Notification.requestPermission()

  notification = new Notification(title, options)
  notification.onshow = ->
    if timeout? && timeout > 0
      setTimeout(notification.close.bind(notification), timeout)
  notification.onclick = ->
    if (onClickUrl)
      window.open(onClickUrl)

markWorkDone = (summary) ->
  console.log "Marking PR as done:", summary
  {title, options} = notifications[summary.status](summary)
  showTimedNotification title, options, summary.url, -1

mergePull = (summary) ->
  # chrome.tabs.create {url: summary.url+"?mergenow", active: false}
  markWorkDone summary

latestStatus = (url, callback) ->
  $.get url, (data) ->
    # See http://stackoverflow.com/questions/14667441/jquery-unrecognized-expression-on-ajax-response
    $dom = $($.parseHTML(data))
    doc = document.implementation.createHTMLDocument("root")
    # window.doc = $(doc)
    $(doc.body).append($dom)
    callback github.pullRequest.summary(url, $(doc)), $(doc)

waitForChange = (summary, callback) ->
  if !store.isEnqueued(summary.url)
    console.log "Stopping task", summary
    return
  {url} = summary

  requeue = ->
    setTimeout((-> waitForChange(summary, callback)), RETRY_INTERVAL)

  latestStatus(url, (newSummary) ->
    if newSummary.status != 'pending'
      callback()
    else
      console.log "No updates, retrying in #{RETRY_INTERVAL/1000.0}s.", url, newSummary
      requeue()
  ).fail requeue

mergeWhenPassed = (task) ->
  if store.isEnqueued(task.url)
    console.log "Task is already enqueued!", task
    return

  resolvePull = ->
    latestStatus task.url, (result) ->
      console.log "Resolving", result
      if result.status is 'passed'
        mergePull result
      else
        markWorkDone result
      setTimeout (-> store.resolve task), 1000

  chain = [
    _.partial store.enqueue, task
    _.partial waitForChange, task
  ]
  async.series chain, resolvePull

chrome.extension.onMessage.addListener (request) ->
  console.log 'Received message', request
  switch request.type
    when 'merge-pending-when-passed' then mergeWhenPassed(request.summary)
    when 'cancel-task' then store.resolve(request.summary)
