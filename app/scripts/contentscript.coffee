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

# Github doesn't do full reloads on state changes, but rather uses pushState so
# poll for that
onPageChange = (callInitial, callback) ->
  if callInitial
    callback()

  oldUrl = document.URL
  setInterval ->
    if document.URL != oldUrl
      callback()
      oldUrl = document.URL
  , 400

waitUtilVisible = (selector, callback) ->
  count = $(selector).length
  if count is 0
    setTimeout (-> waitUtilVisible selector, callback), 50
  else
    callback()

onPageChange true, ->
  console.debug("page changed", document.URL)
  $(".extn-lgtm").remove()
  if isPullRequestPage()
    waitUtilVisible ".gh-header-title", updateSite

if location.search == "?mergenow"
  $("form.merge-branch-form").submit()
  setTimeout((-> window.close()), 300)
