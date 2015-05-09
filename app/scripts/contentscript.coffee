'use strict'

store = new TaskStore()

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

  # console.debug "Sending message:", message, summary
  chrome.extension.sendMessage message

cancelCurrentTask = () ->
  chrome.extension.sendMessage {
    message: 'cancel-task'
    summary: currentSummary()
  }

window.Renderer =
Renderer =
  pageState: ->
    summary = currentSummary()
    if !summary || !summary.canMerge || summary.status != 'pending'
      Renderer.states.vanilla
    else if store.isEnqueued summary
      Renderer.states.enqueued
    else
      Renderer.states.button

  renderState: (state) ->
    if Renderer.prevState? isnt state
      Renderer.prevState?.unrender()
      state.render()
      Renderer.prevState = state

  renderCurrentState: ->
    newState = Renderer.pageState()
    if newState != Renderer.prevState
      console.log "Switching page state from %s to %s",
        Renderer.prevState.name,
        newState.name
    Renderer.renderState newState

  states:
    vanilla:
      name: 'vanilla'
      render: ->
      unrender: ->
    button:
      name: 'button'
      render: ->
        button = $('''
          <button class="btn btn-outline extn-lgtm" style="float: left;">
            <span class="octicon octicon-primitive-dot text-pending"></span>
            Merge when tests pass
          </button>
        ''')
        $('.commit-form-actions').prepend button
        button.on "click", ->
          sendTask currentSummary()
          button.prop("disabled", true)
          $(".merge-form-contents .js-details-target").click()
      unrender: ->
        $(".extn-lgtm").remove()
    enqueued:
      name: 'enqueued'
      render: ->
        $parent = $(".merge-message .js-details-container")
        $parent.find(".merge-branch-heading").hide()
        $parent.find(".merge-branch-description").hide()
        $(".merge-branch-action").hide()

        snippet = $('''
          <h3 class="extn-lgtm merge-branch-heading text-pending">
            Merging this pull request if checks succeed.
          </h3>
          <p class="extn-lgtm merge-branch-description">
            Want to abort? Click <a href class="extn-lgtm-cancel">here</a>.
          </p>
        ''')
        $parent.prepend(snippet)
        snippet.on 'click', '.extn-lgtm-cancel', ->
          cancelCurrentTask()
          false

      unrender: ->
        $(".extn-lgtm").remove()
        $parent = $(".merge-message .js-details-container")
        $parent.find(".merge-branch-heading").show()
        $parent.find(".merge-branch-description").show()
        $(".merge-branch-action").show()

_current = null
currentSummary = () ->
  if isPullRequestPage() && _current isnt null
    _current

updateSite = ->
  summary = _current = github.pullRequest.summary(document.URL)
  console.debug "PR is:", summary, Renderer.pageState().name, store.isEnqueued summary
  Renderer.renderCurrentState()

# Github doesn't do full reloads on state changes, but rather uses pushState so
# poll for that
onPageChange = (callInitial, callback) ->
  store.refresh(callback) if callInitial
  oldUrl = document.URL
  setInterval ->
    if document.URL != oldUrl
      oldUrl = document.URL
      store.refresh callback
  , 400

waitUntilVisible = (selector, callback) ->
  count = $(selector).length
  if count is 0
    setTimeout (-> waitUntilVisible selector, callback), 50
  else
    callback()

onPageChange true, ->
  # console.debug("page changed", document.URL)
  Renderer.renderState(Renderer.states.vanilla)
  if isPullRequestPage()
    waitUntilVisible ".gh-header-title", updateSite

store.watch ->
  console.log "Store changed, updating!"
  updateSite()

if location.search == "?mergenow"
  $("form.merge-branch-form").submit()
  setTimeout((-> window.close()), 300)
