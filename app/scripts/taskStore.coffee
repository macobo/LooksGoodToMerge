key = (task) -> "#{task.url}"
asyncify = (callback) -> (result) ->
  if callback?
    callback null, result

root = exports ? this
root.TaskStore =
class TaskStore
  constructor: ->
    @storage = chrome.storage.local
    @currentState = {}
    @refresh()
    @_dirty = false
    @watch()

  refreshMaybe: (callback) ->
    if @_dirty
      @refresh(callback)
    else if callback?
      callback(@currentState)

  refresh: (callback) =>
    @storage.get null, (result) =>
      @_dirty = false
      @currentState = result
      unless $.isEmptyObject @currentState
        console.debug "Tasks that are onway:", @currentState
      callback(@currentState) if callback?

  enqueue: (task, callback) =>
    console.debug('Enqueue task', task.url)
    k = {}
    k[key(task)] = true
    @currentState[key(task)] = true
    @storage.set k, asyncify(callback)

  resolve: (task, callback) =>
    console.debug('Resolving task', task.url)
    @storage.remove key(task), asyncify(callback)
    @_dirty = true

  isEnqueued: (task) =>
    @currentState[key(task)] ? false

  watch: (callback) =>
    chrome.storage.onChanged.addListener (changes) =>
      @refresh callback
