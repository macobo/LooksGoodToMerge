root = exports ? this

statusRules = [
  [".text-success", "passed"]
  [".text-failure", "failed"]
  [".text-error", "failed"]
  [".text-pending", "pending"]
  [".branch-action-state-merged", "merged"]
  [".branch-action-state-closed-dirty", "closed"]
]

extractPullStatus = ($dom) ->
  $dom ||= $(document)
  ruleMatches = ([partialSelector, cls]) ->
    selector = "#partial-pull-merging #{partialSelector}"
    matching = $dom.find selector
    matching.length > 0

  result = _(statusRules).find ruleMatches
  result[1] ? 'unknown'

canMerge = ($dom) ->
  $dom ||= $(document)
  button = $dom.find(".btn.merge-branch-action:disabled")
  console.log(button)
  button.length == 0

root.github = {
  extractPullStatus
  canMerge
}

# console.log(window, this, extractPullStatus($(document)))
