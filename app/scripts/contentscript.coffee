'use strict'

isPullRequestPage = (url) ->
  /github\.com\/.*\/.*\/pull\/\d+\/?$/.test(url || document.URL)

sendTask = (summary) ->
  message =
    type: 'merge-pending-when-passed'
    summary: summary

  console.debug "Sending message:", message, summary
  chrome.extension.sendMessage message

addButton = (summary, $parent) ->
  button = $('''
    <button id="extn-lgtm-merge-btn" class="btn btn-outline extn-lgtm" style="float: left;">
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

# Github doesn't do full reloads on state changes, but rather uses push
onPageChange = (callInitial, callback) ->
  if !callback?
    callback = callInitial
    callInitial = false
  oldUrl = if callInitial then undefined else document.URL
  setInterval ->
    if document.URL != oldUrl
      oldUrl = document.URL
      callback()
  , 400

onPageChange true, ->
  console.debug("page changed", document.URL)
  if isPullRequestPage()
    updateSite()
  else
    $(".extn-lgtm").remove()

if location.search == "?mergenow"
  $("form.merge-branch-form").submit()
  setTimeout((-> window.close()), 300)
