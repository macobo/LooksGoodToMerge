'use strict'

RETRY_INTERVAL = 3000

# chrome.runtime.onInstalled.addListener (details) ->
#   console.log('previousVersion', details.previousVersion)

# console.log('\'Allo \'Allo! Event Page')

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
  showTimedNotification(status, {}, url, 5000)

checkPassed = (startState, url) ->
  console.debug "checking on #{url} (start state: #{url})"
  requeue = ->
    setTimeout((-> checkPassed(startState, url)), RETRY_INTERVAL)


  $.get(url, (data) ->
    # See http://stackoverflow.com/questions/14667441/jquery-unrecognized-expression-on-ajax-response
    $dom = $($.parseHTML(data))
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
