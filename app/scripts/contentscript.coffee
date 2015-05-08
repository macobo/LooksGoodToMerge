'use strict'

addButton = ($parent) ->
  button = '''
    <span id="ext-merge-btn" class="btn btn-outline" style="float: left;">
      <span class="octicon octicon-primitive-dot text-pending"></span>
      Merge when tests pass
    </span>
  '''
  $parent.on("click", "#ext-merge-btn", -> console.log("hi"))
  $parent.prepend(button)

message = {
  type: 'notify-passed'
  url: document.URL
  summary: github.pullRequest.summary(document.URL)
}
console.log 'current PR:', message, github.pullRequest.summary(document.URL)

# chrome.extension.sendMessage(message)
addButton($('.commit-form-actions'))
