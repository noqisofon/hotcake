root = exports ? this

root.app.controller( 'HotcakeApp', [ '$scope', 'HotcakeSlot', 'HotcakeColumn', 'AppService', 'SliderService',
'DialogService', 'ConnectionManager', 'HotcakeDaemon', 'RelationService', 'MessageService', 'Logger'
($scope, HotcakeSlot, HotcakeColumn, AppService, SliderService, DialogService, ConnectionManager, HotcakeDaemon, RelationService, MessageService, Logger) !->
  resize-timer = null

  $scope.props =
    compose-btn-expand-class: ''

  $scope.splash =
    show: true
    fade-out: false
    text: 'loading ...'

  $scope.guide =
    show: false
    fade-out: false
    add-slot:
      show: false
      text: 'Add an acount here'

  $scope.masks =
    show: true

  $scope.notify-bar =
    show: false
    text: 'No thing new here'
    link: '#'
    link-icon: ''

  $scope.search-entry =
    text: ''
    expand: ''

  $scope.search-layer =
    show: ''
    cls: ''

  $scope.slots = [ {}, {}, {} ]
  $scope.current-slot = SliderService.current-slot

  $scope.$on( 'SliderUpdate'    , -> refresh-slit-list() )
  
  $scope.$on( 'AppTriggerResize', -> resize() )
  
  $scope.$on( 'SliderChangeSlot', -> resize() )
  
  $scope.$on( 'SliderNoModeSlot', ->
    hide-me()
    check-slot()
  )
  
  $scope.$on( 'SliderDeleteSlot', ->
    when-slot-deleted( SliderService.delete-slot-params.serv, SliderService.delete-slot-params.name )
  )

  hide-me = ->
    curent-window = Hotcake.window.current()
    curent-window.hide()

  show-me = ->
    curent-window = Hotcake.window.current()

    curent-window.show()
    curent-window.focus()
    curent-window.draw-attention()

    Logger.info( 'init layout' )

    set-timeout( tigger-resize                    , 1000 )
    set-timeout( ->
      $scope.splash.fade-out = true
    , 1000 )
    set-timeout( ->
      check-update()
    , 5000 )

  check-slot = (callback) ->
    check-slot-aux ->
      HotcakeSlot.all( (_slots) ->
        if _slots.length == 0
          # wating
          set-timeout( check-slot-aux, aux )
        else
          show-me()
          callback()
      )
    HotcakeSlot.all(  (_slots) ->
      if _slots.length == 0
        DialogService.open-new-slot-dialog()
      check-slot-aux()
    )

  set-up-context-menu = !->
    chrome.context-menus.remove-all( !->
      chrome.context-menus.create(
        title: 'Reply'
        id: 'context_menu_reply'
        target-url-patterns: [ 'chrome-extension://*/more' ]
        context: <[ link ]>
      )
      chrome.context-menus.create(
        title: 'Quote'
        id: 'context_menu_quote'
        target-url-patterns: [ 'chrome-extension://*/item' ]
        context: <[ link ]>
      )
      chrome.context-menus.create(
        title: 'All'
        id: 'context_menu_all'
        target-url-patterns: [ 'chrome-extension://*/*' ]
        context: <[ link ]>
      )
    )

  when-slot-deleted = (serv, name) !->
    HotcakeDaemon.unbind-verifier( serv, name )
    RelationService.unbind( serv, name )

  verify-slot = (a-slot) !->
    client = ConnectionManager.get-connection( a-slot.serv, a-slot.name )
    client.verify(
      (profile) ->
        verify-OK( a-slot, profile )
      , ->
        verify-error( a-slot )
    )
    client.get-followings(
      a-slot.name
      , (ids) ->
        RelationService.update-following-ids( a-slot.serv, a-slot.name, ids )
      , ->
        Logger.info( "Failed to get followings of #{a-slot.serv}/#{a-slot.key}" )
    )

  verify-OK = (a-slot, profile) !->
    SliderService.update-slot-avatar( a-slot.serv, a-slot.name, profile.avatar-url )
    SliderService.update-slot-profile( a-slot.serv, a-slot.name, profile )

  verify-error = (a-slot) !->
    Logger.info( "Failed to verify this slot #{a-slot.serv}/#{a-slot.key}" )

  refresh-slot-list = (a-slot) !->
    $scope.slots.length = 0
    for k, i in SliderService.slot-list
      $scope.slots.push()
    $scope.current-slot = SliderService.current-slot

  $scope.has-new-message = ->
    if SliderService.current-slot
      count = SliderService.get-new-message-count( SliderService.current-slot.serv, SliderService.current-slot.name )
      return true unless count == 0
    false

  $scope.toggle-search-mode = !->
    if $scope.search-entry.expand
      $scope.leave-seaech-mode()
    else
      $scope.enter-seaech-mode()

  $scope.enter-seaech-mode = !->
    $scope.search-entry.expand = true
    $scope.search-layer.show   = true
    $scope.search-layer.cls    = 'slide'

    set-timeout( ->
      document.query-selector '.search-entry' .focus()
    , 500 )

  $scope.leave-seaech-mode = ->
    $scope.search-entry.expand = false
    $scope.search-layer.show   = false
    $scope.search-layer.cls    = ''

  $scope.get-search-layer-cls = ->
    $scope.search-layer.cls

  $scope.get-search-entry-styles = ->
    return { width: '180px' } if $scope.search-entry.expand
    { width: '0' }

  $scope.handle-search-entry-keyup = (evt) !->
    if evt.key-code == 27    # ESC
      $scope.leave-seaech-mode()
    else if evt.key-code == 13
      keywords = $scope.search-entry.text.trim()
      search( keywords )

  search = (keywords) ->
    AppService.broadcast( 'search', { keywords: keywords } )

  $scope.select-slot = (a-slot, index) ->
    SliderService.current-slot = SliderService.slot-list[index].slot
    SliderService.broadcast( 'change-slot' )

  $scope.open-columns-dialog = !->
    if SliderService.current-slot
      DialogService.open-columns-dialog( SliderService.current-slot )

  $scope.open-message-dialog = !->
    if SliderService.current-slot
      MessageService.clear-new-message-count( SliderService.current-slot.serv, SliderService.current-slot.name )
      DialogService.open-message-dialog( SliderService.current-slot )

  $scope.open-profile-dialog = !->
    if SliderService.current-slot
      DialogService.open-profile-dialog( SliderService.current-slot )

  # layout
  $scope.int-app = ->
    # set-up-context-menu
    HotkeyService.register( [ Hotkey.CMD, \N ], open-compose-dialog )
    HotkeyService.register( [ Hotkey.CMD, \1 ], (evt) -> SliderService.trigger-slide-to( 1 ) )
    HotkeyService.register( [ Hotkey.CMD, \2 ], (evt) -> SliderService.trigger-slide-to( 2 ) )
    HotkeyService.register( [ Hotkey.CMD, \3 ], (evt) -> SliderService.trigger-slide-to( 3 ) )
    HotkeyService.register( [ Hotkey.CMD, \4 ], (evt) -> SliderService.trigger-slide-to( 4 ) )
    HotkeyService.register( [ Hotkey.CMD, \5 ], (evt) -> SliderService.trigger-slide-to( 5 ) )
    HotkeyService.register( [ Hotkey.CMD, \6 ], (evt) -> SliderService.trigger-slide-to( 6 ) )
    
    HotkeyService.register( [             \J ], (evt) -> SliderService.select-next-item() )
    HotkeyService.register( [             \K ], (evt) -> SliderService.select-prev-item() )
    
    HotkeyService.register( [             \H ], (evt) -> SliderService.trigger-slide-prev() )
    HotkeyService.register( [             \L ], (evt) -> SliderService.trigger-slide-next() )
    
    HotkeyService.register( [ Hotkey.CMD, \J ], (evt) -> SliderService.select-last-item() )
    HotkeyService.register( [ Hotkey.CMD, \K ], (evt) -> SliderService.select-first-item() )
    HotkeyService.register( [ Hotkey.CMD, \R ], (evt) -> reply-selected() )
    HotkeyService.register( [ Hotkey.CMD, \T ], (evt) -> repost-selected() )

    HotkeyService.register( [ Hotkey.CMD, Hotkey.SHIFT, \T ], (evt) -> quote-selected() )
    HotkeyService.register( [ Hotkey.CMD, Hotkey.SHIFT, \R ], (evt) -> Hotcake.runtime.reload() )
    
    HotkeyService.register( [ Hotkey.CMD, \Q ], (evt) -> window.close() )
    HotkeyService.register( [ Hotkey.CMD, \W ], (evt) -> window.close() )
    HotkeyService.register( [ Hotkey.CMD, \I ], (evt) -> DialogService.open-people-dialog() )

    check-slot( ->
      HotcakeSlot.all( (slots) ->
        for slot in slots
          HotcakeDeamon.bind-verifier( slot.serv, slot.name, -> verifi-slot( slot ) )
          RelationService.bind( slot.serv, slot.name )
      )
      $scope!$apply( -> refresh-slot-list )
    )

  $scope.guide-hide-cls = ->
    return if $scope.guide.fade-out then \fade-out else ''

  $scope.guide-ani-end = !->
    $scope.guide.show = false
    $scope.masks.show = false if $scope.guide.show == false and $scope.splash.show == false

  $scope.splash-ani-end = !->
    $scope.splash.show = false
    $scope.masks.show = false if $scope.guide.show == false and $scope.splash.show == false

  $scope.hide-guide = !->
    $scope.guide.fade-out = true

  $scope.get-notify-bar-link-icon = ->
    $scope.notify-bar.link-icon

  $scope.open-compose-dialog = (evt) ->
    open-compose-dialog( evt )

  open-compose-dialog = (evt) ->
    DialogService.open-compose-dialog( SliderService.current-slot )
    true

  $scope.current-slot-available = ->
    return if SliderService.current-slot then
      true
    else
      false

  $scope.open-settings-dialog = (evt) ->
    if evt.alt-key then
      DialogService.open-log-dialog()
    else
      DialogService.open-settings-dialog()
    true

  $scope.open-new-slot-dialog = ->
    DialogService.open-new-slot-dialog()

  angular.element window .bind( \resize , !->
    if @resize-timer
      clear-timeout( @resize-timer )
    @resize-timer = set-timeout( trigger-resize, 200 )
  )

  # $scope.get-current-avatar = ->
  #   return SliderService.current-slot.avatar if SliderService.current-slot
  #   ''

  $scope.handle-keydown = (evt) ->
    Hotcake.check-update( (result, ver, url) !->
      if result
        $scope.notify-bar.text = 'A new version of Hotcake is available!'
        $scope.notify-bar.link = url
        $scope.notify-bar.link-icon = 'icon-download-alt'
        $scope.notify-bar.show = true
    )

  get-slot-column-amount = ->
    return SliderService.current-slot.columns.length if SliderService.current-slot
    0

  resize = !->
    body = angular.element( document.querySelector( \body ) )[0]
    client-info =
      width: body.client-width
      height: body.client-height
      main:
        width: body.client-width
        height: body.client-height - 68

    slot =
      column:
        amount: get-slot-column-amount()
        max-amount: parse-int( client.main.width / 300 ) ? 1

    if slot.column.amount < slot.column.max-amount
      slot.column.max-amount = slot.column.amount
    if slot.column.max-amount > 0
      if slot.column.max-amount < 2
        $scope.props.compose-btn-expand-class = ''
      else
        $scope.props.compose-btn-expand-class = \expand

    client-info.max-column-amount = slot.column.max-amount

    set-timeout( ->
      AppService.broadcast( \resize, client-info )
      Hotcake.save-bounds()
    , 100
    )

  trigger-resize = !-> resize()

  reply-selected = !->
    item = SliderService.get-selected-item()
    if item
      DialogService.open-compose-dialog( SliderService.currentSlot,
        type: \replay
        id: item.id
        text: item.raw-text
        author-name: item.author.name
        author-id: item.author.id
        author-avatar-data: item.author.avatar-url
        mentions: item.mentions
      )

  repost-selected = !->
    item = SliderService.get-selected-item()

    perform-respost = (ret) !->
      item.resposted = true
      item.rt-id = ret.rt-id

    perform-undo-repost = (ret) !->
      item.resposted = false
      item.rt-id = ''

    err = !->

    client = ConnectionManager.getConnection( SliderService.current-slot.serv, SliderService.current-slot.name )
    if item.respoted
      client.handle-undo-repost( item.rt-id, perform-undo-repost, err )
    else
      client.handle-undo-repost( item.id, perform-respost, err )

  quote-selected = !->
    item = SliderService.get-selected-item()
    if item
      DialogService.open-compose-dialog( SliderService.currentSlot,
        type: \quote
        id: item.id
        text: item.converted-text
        author-id: item.author.id
        author-name: item.author.name
        mentions: []
      )

] )
