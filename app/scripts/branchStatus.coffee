root = exports ? this

statusRules = [
  [".status-description.text-pending", "pending"]
  # TODO: these should match non-mergable as well!
  [".status-description.text-success", "passed"]
  [".status-description.text-failure", "failed"]
  [".status-description.text-error", "failed"]
  [".branch-action-state-merged", "merged"]
  # This means it's not mergable
  # [".branch-action-state-dirty", "closed"]
  [".branch-action-state-closed-dirty", "closed"]
]

getDocument = (handler) -> ($dom) ->
  handler($dom || $(document))

extractStatus = getDocument ($dom) ->
  ruleMatches = (partialSelector) ->
    selector = "#partial-pull-merging #{partialSelector}"
    matching = $dom.find selector
    matching.length > 0

  for [partial, className] in statusRules
    if ruleMatches partial
      return className
  'unknown'

canMerge = getDocument ($dom) ->
  button = $dom.find('.btn.merge-branch-action:enabled')
  button.length > 0

title = getDocument ($dom) ->
  $dom.find('.js-issue-title').text()

id = getDocument ($dom) ->
  +($dom.find('.gh-header-number').text()[1..])

headSha = getDocument ($dom) ->
  $dom.find('input[name="head_sha"]').prop('value')

csrf_token = getDocument ($dom) ->
  $dom.find('meta[name="csrf-token"]').prop("content")

uuid = getDocument (url) ->
  regex = /github\.com\/([^\/]+)\/([^\/]+)\/pull\/(\d+)/
  [user, repo, _id] = url.match(regex)[1..]
  "uuid:#{user}/#{repo}/#{_id}"

summary = (url, $dom) ->
  {
    title: title($dom)
    id: id($dom)
    canMerge: canMerge($dom)
    status: extractStatus($dom)
    url: url
    uuid: uuid(url)
    sha: headSha($dom)
    csrf_token: csrf_token($dom)
  }

root.github =
  pullRequest: {
    summary
    extractStatus
    canMerge
    title
    id
  }
