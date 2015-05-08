'use strict'

console.log 'current PR is', github.extractPullStatus()

$('#partial-discussion-header .gh-header-meta')
  .append('<button id="ext-merge-btn">test</button>')

message = {
  type: 'notify-passed'
  url: document.URL
  state: github.extractPullStatus(),
}

chrome.extension.sendMessage(message)
