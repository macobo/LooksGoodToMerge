'use strict'

sendTask = (summary) ->
  message =
    type: 'merge-pending-when-passed'
    summary: summary

  console.debug "Sending message:", message, summary
  chrome.extension.sendMessage message

addButton = (summary, $parent) ->
  button = $('''
    <button id="ext-merge-btn" class="btn btn-outline" style="float: left;">
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
  console.log(summary)
  addButton summary, $('.gh-header-title')
  # if (summary.canMerge && summary.status == "pending")
    # addButton summary, $('.commit-form-actions')

if location.search == "?mergenow"
  $("form.merge-branch-form").submit()
  setTimeout((-> window.close()), 300)
else
  updateSite()
