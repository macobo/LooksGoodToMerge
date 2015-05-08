root = exports ? this

statusRules = [
  [".text-success", "passed"]
  [".text-failure", "failed"]
  [".text-error", "failed"]
  [".text-pending", "pending"]
  [".branch-action-state-merged", "merged"]
  [".branch-action-state-closed-dirty", "closed"]
]

getDocument = (handler) -> ($dom) ->
  handler($dom || $(document))

extractStatus = getDocument ($dom) ->
  ruleMatches = ([partialSelector, cls]) ->
    selector = "#partial-pull-merging #{partialSelector}"
    matching = $dom.find selector
    matching.length > 0

  result = _(statusRules).find(ruleMatches)
  if result then result[1] else 'unknown'

canMerge = getDocument ($dom) ->
  button = $dom.find('.btn.merge-branch-action:enabled')
  console.log(button)
  button.length > 0

title = getDocument ($dom) ->
  $dom.find('.js-issue-title').text()

id = getDocument ($dom) ->
  +($dom.find('.gh-header-number').text()[1..])


uuid = getDocument (url) ->
  regex = /github\.com\/([^\/]+)\/([^\/]+)\/pull\/(\d+)$/
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
  }

root.github =
  pullRequest: {
    summary
    extractStatus
    canMerge
    title
    id
  }


# console.log(window, this, extractStatus($(document)))
