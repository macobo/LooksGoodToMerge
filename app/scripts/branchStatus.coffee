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

  [partial, resultType] = _(statusRules).find ruleMatches
  resultType ? 'unknown'

root.github = {
  extractPullStatus
}

# console.log(window, this, extractPullStatus($(document)))