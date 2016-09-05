platform = 0

const PLATFORM_CHROME_OS = 0
const PLATFORM_MAX = 1

const nothing-fn = ->

add-storage-changed-listener = (callback) ->
  return if platform is PLATFORM_CHROME_OS then
    chrome.storage.on-changed.add-listener( callback )
  else
    null

get-local-storage = (id, callback) ->
  return if platform is PLATFORM_CHROME_OS then
    chrome.storage.local.get( id, callback )
  else
    null

set-local-storage = (pair, callback) ->
  return if platform is PLATFORM_CHROME_OS then
    chrome.storage.local.set( pair, callback )
  else
    null

create-window = (page, opts, callback) ->
  return if platform is PLATFORM_CHROME_OS then
    if not callback then
      chrome.app.window.create( page, opts )
    else
      chrome.app.window.create( page, opts, callback )
  else
    null

get-current-window = ->
  return if platform is PLATFORM_CHROME_OS then
    chrome.app.window.current()
  else
    null

add-window-closed-listener = (callback) ->
  return if platform is PLATFORM_CHROME_OS then
    chrome.app.window.on-closed.add-listener( callback )
  else
    null

add-bus-message-listener = (callback) ->
  return if platform is PLATFORM_CHROME_OS then
    chrome.runtime.on-message.add-listener( callback )
  else
    null

send-bus-message = (message, callback) ->
  return if platform is PLATFORM_CHROME_OS then
    if not callback then
      chrome.runtime.send-message( message )
    else
      chrome.runtime.send-message( message, callback )
  else
    null

create-notifications = (id, opts, callback) ->
  if platform is PLATFORM_CHROME_OS then
    _opts =
      type: 'basic'
      title: opts.title
      message: opts.summary
      event-time: opts.timeout
      icon-url: '../icons/128x128/apps/hotcake.png'

    return if not callback then
      chrome.notifications.create( id, _opts, nothing-fn )
    else
      chrome.notifications.create( id, _opts, callback )
  else
    return null

reload-runtime = ->
  return if platform is PLATFORM_CHROME_OS then
    chrome.runtime.reload()
  else
    null

choose-fs-entry = (opts, callback) ->
  return if platform is PLATFORM_CHROME_OS then
    if not callback then
      chrome.file-system.choose-entry( opts, nothing-fn )
    else
      chrome.file-system.choose-entry( opts, callback )
  else
    null

hotcake =
  storage:
    on-changed:
      add-listener: add-storage-changed-listener
    local:
      get: get-local-storage
      set: set-local-storage
  window:
    on-closed:
      add-listener: add-window-closed-listener
    create: create-window
    current: get-current-window
  bus:
    on-message:
      add-listener: add-bus-message-listener
      send-message: send-bus-message
  fs:
    choose-entry: choose-fs-entry
  notifications:
    create: create-notifications
  runtime:
    reload: reload-runtime

this.hotcake = hotcake
