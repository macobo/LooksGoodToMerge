'use strict'

$('#partial-discussion-header .gh-header-meta')
  .append('<button id="ext-merge-btn">test</button>')

message = {
  type: 'notify-passed'
  url: document.URL
  state: github.extractPullStatus(),
  canMerge: github.canMerge()
}
console.log 'current PR:', message

chrome.extension.sendMessage(message)
