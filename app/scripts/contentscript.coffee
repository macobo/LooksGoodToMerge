'use strict'

isPullRequestPage = (url) ->
  ///
    github\.com
    \/.*\/.*
    \/pull\/\d+
  ///.test(url || document.URL)

sendTask = (summary) ->
  message =
    type: 'merge-pending-when-passed'
    summary: summary

  console.debug "Sending message:", message, summary
  chrome.extension.sendMessage message

addButton = (summary, $parent) ->
  button = $('''
    <button class="btn btn-outline extn-lgtm" style="float: left;">
      <span class="octicon octicon-primitive-dot text-pending"></span>
      Merge when tests pass
    </button>
  ''')
  button.on "click", ->
    sendTask(summary)
    button.prop("disabled", true)
  $parent.prepend(button)

updateSite = ->
  summary = github.pullRequest.summary(document.URL)
  console.debug "PR is:", summary
  addButton summary, $('.gh-header-title')
  if (summary.canMerge && summary.status == "pending")
    addButton summary, $('.commit-form-actions')

# Github doesn't do full reloads on state changes, but rather uses pushState
# poll for that
callAtLatest = (timeout, handler) ->
  canHappen = true
  happened = false
  setTimeout(->
    canHappen = false
    if !happened
      console.log "it didn't happen!"
      handler()
  , timeout)
  (args...) ->
    if canHappen
      console.log "called", args, $("title").text()
      canHappen = false
      happened = true
      handler args...

onPageChange = (callInitial, callback) ->
  if !callback?
    callback = callInitial
    callInitial = false
  title = -> $("title").text()
  resolve = ->
    oldTitle = title()
    callback()

  if callInitial
    callback()

  oldUrl = document.URL
  oldTitle = title()
  setInterval ->
    if document.URL != oldUrl
      # Wait until the title changes or up to 5 seconds before continuing
      # This should fix the race if a page loads slowly
      if title() == oldTitle
        $("title").one 'DOMSubtreeModified', callAtLatest(5000, resolve)
      else
        resolve()
      oldUrl = document.URL
  , 400

onPageChange true, ->
  console.debug("page changed", document.URL)
  $(".extn-lgtm").remove()
  if isPullRequestPage()
    updateSite()

if location.search == "?mergenow"
  $("form.merge-branch-form").submit()
  setTimeout((-> window.close()), 300)
