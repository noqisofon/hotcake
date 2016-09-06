root = exports ? this

root.app.factory( 'HotcakeBus', [ '$rootScope', 'AppService', 'NotifyService', 'DialogService', 'SliderService', 'RelationService', 'HotcakeSlot', 'HotcakeColumn', 'HotcakeDraft', 'ConnectionManager', 'HotcakeDaemon', 'SettingsService', 'Logger', 'MessageService',
($rootScope, AppService, NotifyService, DialogService, SliderService, RelationService, HotcakeSlot, HotcakeColumn, HotcakeDraft, ConnectionManager, HotcakeDaemon, SettingsService, Logger, MessageService) ->
  HotcakeBus =
    message-map: {}

    message: null

    ignite-attachment:
      base64-data: null
      raw-data: null
      filename: ''
      type: ''
      size: ''
      file: null

    stop-auth: false

    init: !->
      Logger.info 'init message bus'

      notify = (a-window, command, content, respond) ->
        if HotcakeBus.message-map.has-own-property( command )
          for callback in HotcakeBus.message-map[ command ]
            callback( a-window, command, content, respond )

      hotcake.bus.on-message.add-listener! (message, sender, respond) ->
        # console.log \control, ev
        win = message.win
        command = message.command
        content = message.content
        # console.log 'Messagebus receives a mennsage: ', win, command, content
        HotcakeBus.crack a-window, command, content, respond
        notify a-window, command, content, respond
        true

    register: (command, callback) !->
      if HotcakeBus.message-map.has-own-property( command )
        HotcakeBus.message-map[command].push( callback )
      else
        HotcakeBus.message-map[command] = [ callback ]

    crack: (win, command, content, respond) !->
      switch command
        when \auth
          HotcakeBus.authorize content.serv, content.username, content.password, respond
        when \oauth_get_authorize_url
          HotcakeBus.get-OAuth-authorize-URL content.serv, content.username, respond
        when \oauth_with_pin
          HotcakeBus.authorize-with-pin content.serv, content.username, content.password, content.pin, respond
        when \cancel_auth
          HotcakeBus.stop-auth = true
        when \auto_complete
          HotcakeBus.auto-complete content.serv, content.text
        when \ignite
          HotcakeBus.ignite content, respond
        when \drop
          HotcakeBus.drop content, respond
        when \update_profile
          HotcakeBus.update-profile content, respond
        when \update_avatar
          HotcakeBus.update-avatar content, respond
        when \share_media
          HotcakeBus.share-media content.media, respond
        when \delete_draft
          HotcakeBus.delete-draft content.uuid, respond
        when \create_draft
          HotcakeBus.create-draft content, respond
        when \create_account
          HotcakeBus.request-create-acount()
        when \delete_account
          HotcakeBus.delete-draft content.serv, content.slot-name, respond
        when \create_column
          HotcakeBus.create-column content, respond
        when \delete_column
          HotcakeBus.delete-column content, respond
        when \move_column
          HotcakeBus.move-column content, respond
        when \save_column_mute
          HotcakeBus.save-column-mute content, respond
        when \save_global_mute
          HotcakeBus.save-global-mute content.account, conent.slot-name, respond
        when \column_notify_on
          HotcakeBus.toggle-column-notification content, on, respond
        when \column_notify_off
          HotcakeBus.toggle-column-notification content, off, respond
        when \whisper
          HotcakeBus.whisper content.key, content.value, respond
        when \follow_people
          HotcakeBus.follow-people content.serv, content.slot-name, content.user-name, respond
        when \unfollow_people
          HotcakeBus.unfollow-people content.serv, content.slot-name, content.user-name, respond
        when \block_people
          HotcakeBus.block-people content.serv, content.slot-name, content.user-name, respond
        when \unblock_people
          HotcakeBus.unblock-people content.serv, content.slot-name, content.user-name, respond
        when \mark_spam_people
          HotcakeBus.mark-spam-people content.serv, content.slot-name, content.user-name, respond
        when \mention_people
          HotcakeBus.mention-people content.serv, content.slot-name, content.name, respond
        when \message_people
          HotcakeBus.message-people content.serv, content.slot-name, content.name, respond
        when \do_reply_item
          HotcakeBus.reply-item content.serv, content.slot-name, content.item, respond
        when \do_repost_item
          HotcakeBus.repost-item content.serv, content.slot-name, content.item, respond
        when \do_quote_item
          HotcakeBus.quote-item content.serv, content.slot-name, content.item, respond
        when \do_delete_item
          HotcakeBus.delete-item content.serv, content.slot-name, content.item, respond
        when \do_preview_item
          HotcakeBus.preview-item content.media, respond
        when \do_view_people
          HotcakeBus.view_people content.serv, content.slot-name, content.user-name, respond
        when \do_load_people_timeline
          HotcakeBus.load-people-timeline content.serv, content.slot-name, content.user-name, content.window-id, respond
        when \do_load_people_follower
          HotcakeBus.load-people-follower content.serv, content.slot-name, content.user-name, content.window-id, respond
        when \do_load_people_following
          HotcakeBus.load-people-following content.serv, content.slot-name, content.user-name, content.window-id, respond
        when \do_load_people_favorite
          HotcakeBus.load-people-favorite content.serv, content.slot-name, content.user-name, content.window-id, respond


    create-column: (conent, respond) !->
      account = content.account
      type    = content.type
      params  = content.params

      SliderService.add-column account.serv, account.name, type, params, (ok, msg) !->
        if ok
          console.log 'create column done.'
          respond( { result: \ok, content: { column: msg } } )
        else
          console.log "create column failed, error: #{msg}"
          respond( { result: \error, reason: 'failed to create the column' } )

    delete-column: (conent, respond) !->
      account = content.account
      name    = content.name

      SliderService.remove-column account.serv, account.name, name, (ok, msg) !->
        if ok
          console.log "delete column #{account.serv}/#{account.name}/#{name} done."
          respond { result: \ok, content: { name: name } }
        else
          console.log "delete column #{account.serv}/#{account.name}/#{name} failed, error: #{msg}"
          respond { result: \error, reason: 'failed to delete the column' }

    move-column: (content, respond) !->
      account = content.account
      start   = content.start
      drop    = content.drop

      SliderService.move-column start, drop

    save-column-mute: (account, column-name, mute, respond) !->
      SliderService.update-column-mute account.serv, account.name, column-name, mute, (ret, msg) !->
        if ret is true
          respond { result: \ok }
        else
          respond { result: \error, reason: msg }

    save-global-mute: (mute, respond) !->
      SettingService.set-mute mute
      respond { result: \ok }

    toggle-column-notification: (content, value, repond) !->
      account = content.account
      name = content.name

      column = SliderService.get-column account.serv, account.name, name
      column.notification = value

      SliderService.update-column column, (ok, msg) !->
        if ok
          console.log "update column #{account.serv}/#{account.name}/#{name} done."
          respond { result: \ok, content: { value: value } }
        else
          console.log "update column #{account.serv}/#{account.name}/#{name} failed, error: #{msg}"
          respond { result: \error, reason: 'failed to update the column' }

    create-draft: (content, respond) !->
      draft = HotcakeDraft.build-defaults()
      draft.text = content.text

      if content.context
        draft.content-type = content.context.type
        draft.content-text = content.context.text
        draft.content-id = content.context.id

      HotcakeDraft.save draft, !->
        HotcakeDraft.all (drafts) ->
          respond { result: \ok, content: { drafts: drafts } }

    delete-draft: (uuid, respond) !->
      HotcakeDraft.remove uuid, !->
        HotcakeDraft.all (drafts) ->
          respond { result: \ok, content: { drafts: drafts } }

    request-create-account: !->
      DialogService.open-new-slot-dialog()

    delete-account: (serv, slot-name) !->
      SliderService.remove-slot serv, slot-name, (ok) !->
        if ok
          HotcakeSlot.all (accounts) !->
            hotcake.bus.send-message(
              win: \main
              command: \reset_settings
              content:
                settings: SettingsService.settings
                accounts: accounts
            )

          client = ConnectionManager.getConnection serv, slot-name

          HotcakeColumn.get-by-slot serv, slot-name, (columns) !->
            for column in columns
              if client.support-stream and client.supprt-sub-stream[column.name]
                HotcakeDaemon.unbind-stream serv, slot-name, column.name, column.name

          HotcakeDaemon.unbind-verifier serv, slot-name
          SliderService.remove-column-by-slot serv, slot-name, ->

    auto-complete: (serv, text, respond) !->
      users = RelationService.find serv, \*, text
      respond { result: \ok, items: users }

    ignite: (content, respond) !->
      ok = (item) !->

      err = !->
        HotcakeBus.create-draft content, respond
        Logger.info 'Failed to update status, save as draft'

      for account in content.accounts
        connection = ConnectionManager.get-connection account.serv, account.name

        if connection
          if content.has-attachment
            conent.attachment.data = Hotot.data-URL2-uint8-array content.attachment.base64-data
        else
          Logger.info 'connection is not available'

    whisper: (key, value, respond) ->
      SettingsService.set-forbiddens key, value
      NotifyService.notify "Whisper: #{key}=#{value}", 'You may need to restart to take effects'

    follow-people: (serv, slot-name, screen-name, respond) !->
      connection = ConnectionManager.get-connection serv, slot-name
      connection.handle-follow screen-name, (user) !->
        user = RelationService.get-by-name serv, slot-name, screen-name

        if user isnt null
          switch user.relationship
            when Hotcake.Relationship.FOLLOWED
              user.relationship = RelationService.set-relationship serv, slot-name, user.name, Hotcake.Relationship.FRIENDS
              # user.relationship = Hotcake.Relationship.FRIENDS
            when Hotcake.Relationship.STRANGER
              user.relationship = RelationService.set-relationship serv, slot-name, user.name, Hotcake.Relationship.FOLLOWING
              # user.relationship = Hotcake.Relationship.FOLLOWING

        respond { result: \ok, content: { user: user } }

    unfollow-people: (serv, slot-name, screen-name, respond) !->
      connection = ConnectionManager.get-connection serv, slot-name
      connection.handle-unfollow screen-name, (user) !->
        user = RelationService.get-by-name serv, slot-name, screen-name

        if user isnt null
          switch user.relationship
            when Hotcake.Relationship.FRIENDS
              user.relationship = RelationService.set-relationship serv, slot-name, user.name, Hotcake.Relationship.FOLLOWED
              # user.relationship = Hotcake.Relationship.FOLLOWED
            when Hotcake.Relationship.FOLLOWING
              user.relationship = RelationService.set-relationship serv, slot-name, user.name, Hotcake.Relationship.STRANGER
              # user.relationship = Hotcake.Relationship.STRANGER

        respond { result: \ok, content: { user: user } }

    block-people: (serv, slot-name, screen-name, respond) !->
      connection = ConnectionManager.get-connection serv, slot-name

      connection.handle-block screen-name, (user) ->
        user = RelationService.get-by-name serv, slot-name, screen-name

        if user isnt null
          user.relationship = RelationService.set-relationship serv, slot-name, user.name, Hotcake.Relationship.BLOCKED
          # user.relationship = Hotcake.Relationship.BLOCKED
        
        respond { result: \ok, content: { user: user } }

    unblock-people: (serv, slot-name, screen-name, respond) !->
      connection = ConnectionManager.get-connection serv, slot-name

      connection.handle-unblock screen-name, (user) ->
        user = RelationService.get-by-name serv, slot-name, screen-name

        if user isnt null
          user.relationship = RelationService.set-relationship serv, slot-name, user.name, Hotcake.Relationship.STRANGER
          # user.relationship = Hotcake.Relationship.STRANGER
        
        respond { result: \ok, content: { user: user } }

    mark-spam-people: (serv, slot-name, screen-name, respond) !->
      connection = ConnectionManager.get-connection serv, slot-name

      connection.handle-mark-spam-people screen-name, (user) ->
        user = RelationService.get-by-name serv, slot-name, screen-name

        if user isnt null
          user.relationship = RelationService.set-relationship serv, slot-name, user.name, Hotcake.Relationship.BLOCKED
          # user.relationship = Hotcake.Relationship.BLOCKED
        
        respond { result: \ok, content: { user: user } }

    mention-people: (serv, slot-name, name, respond) !->
      DialogService.open-compose-dialog SliderService.current-slot, { response: "@#{name}" }

    message-people: (serv, slot-name, name, respond) !->
      DialogService.open-message-dialog SliderService.current-slot, { name: name }

    preview-media: (a-media, respond) !->
      opts = {}
      DialogService.open-preview-dialog opts, a-media

    view-people: (serv, slot-name, user-name, respond) !->
      relationship = Hotcake.Relationship.UNKNOWN
      user         = RelationService.get-by-name serv, slot-name, user-name
      slot         = SliderService.get-slot serv, slot-name

      if slot is null then
        return

      client  = ConnectionManager.get-connection serv, slot-name
      timeout = (time) -> Date.now() - time > 3600000     # 1 hour

      if user isnt null
        # @TODO: should compare user.name with myself.name, not slot.name
        if Hotcake.same-name user.name, slot.name
          user.relationship = Hotcake.Relationship.SELF
          relationship      = user.relationship

      DialogService.open-people-dialog slot, user, (a-window) !->
        if user is null or timeout( user.create-time )
          client.get-user user-name, (user) !->
            RelationService.add serv, slot-name, [ user ]
            if RelationService.is-following serv, slot-name, user
              user.is-following = true

            hotcake.bus.send-message { recipient: a-window.id, role: \column, command: \set_people_user, content: { user: user } }

        if relationship is Hotcake.Relationship.UNKNOWN
          client.get-relationship slot.name, user-name, (relationship) !->
            RelationService.set-relationship serv, slot-name, user-name, relationship
            hotcake.bus.send-message { recipient: a-window.id, role: \column, command: \set_people_relationship, content: { relationship: relationship } }

        client.handle-column-load {
          type: \people
          params: [ user-name, '' ]
          position-arg1: ''
          position-arg2: ''
        }, (items) !->
          hotcake.bus.send-message { recipient: a-window.id, role: \column, command: \set_people_timeline, content: { items: items, settings: SettingsService.settings }  }
        , (data) !->
          details = if data.constructor is String then
            data
          else
            JSON.stringify data
          hotcake.bus.send-message { recipient: a-window.id, role: \column, command: \set_people_timeline, result: \error, reason: details }

    load-people-timeline: (serv, slot-name, user-name, window-id, respond) !->
      client = ConnectionManager.get-connection serv, slot-name

      client.handle-column-load {
        type: \people
        params: [ user-name, '' ]
        position-arg1: ''
        position-arg2: ''
      }, (items) !->
        hotcake.bus.send-message { recipient: window-id, role: \column, command: \set_people_timeline, content: { items: items, settings: SettingsService.settings }  }
      , (data) !->
        details = if data.constructor is String then
          data
        else
          JSON.stringify data
        hotcake.bus.send-message { recipient: window-id, role: \column, command: \set_people_timeline, result: \error, reason: details }

    load-people-follower: (serv, slot-name, user-name, window-id, respond) !->
      client = ConnectionManager.get-connection serv, slot-name

      client.handle-column-load {
        type: \follower
        params: [ user-name, '' ]
        position-arg1: '-1'
        position-arg2: ''
      }, (items) !->
        hotcake.bus.send-message { recipient: window-id, role: \column, command: \set_people_timeline, content: { items: items, settings: SettingsService.settings }  }
      , (data) !->
        details = if data.constructor is String then
          data
        else
          JSON.stringify data
        hotcake.bus.send-message { recipient: window-id, role: \column, command: \set_people_timeline, result: \error, reason: details }

    load-people-following: (serv, slot-name, user-name, window-id, respond) !->
      client = ConnectionManager.get-connection serv, slot-name

      client.handle-column-load {
        type: \following
        params: [ user-name, '' ]
        position-arg1: '-1'
        position-arg2: ''
      }, (items) !->
        hotcake.bus.send-message { recipient: window-id, role: \column, command: \set_people_timeline, content: { items: items, settings: SettingsService.settings }  }
      , (data) !->
        details = if data.constructor is String then
          data
        else
          JSON.stringify data
        hotcake.bus.send-message { recipient: window-id, role: \column, command: \set_people_timeline, result: \error, reason: details }

    load-people-favorite: (serv, slot-name, user-name, window-id, respond) !->
      client = ConnectionManager.get-connection serv, slot-name

      client.handle-column-load {
        type: \favorite
        params: [ user-name, '' ]
        position-arg1: ''
        position-arg2: ''
      }, (items) !->
        hotcake.bus.send-message { recipient: window-id, role: \column, command: \set_people_timeline, content: { items: items, settings: SettingsService.settings }  }
      , (data) !->
        details = if data.constructor is String then
          data
        else
          JSON.stringify data
        hotcake.bus.send-message { recipient: window-id, role: \column, command: \set_people_timeline, result: \error, reason: details }

    reply-item: (serv, slot-name, item, respond) !->
      slot = SliderService.get-slot serv, slot-name

      if slot is null then
        return

      DialogService.open-compose-dialog slot,
        id: item.id
        type: \reply
        text: item.raw-text
        author-id: item.author-id
        author-name: item.author-name
        author-avatar-data: item.feature-pic-data
        mentions: item.mentions

    quote-item: (serv, slot-name, item, respond) !->
      slot = SliderService.get-slot serv, slot-name

      if slot is null then
        return

      DialogService.open-compose-dialog slot,
        id: item.id
        type: \quote
        text: item.raw-text
        author-id: item.author-id
        author-name: item.author-name
        mentions: []

    favorite-item: (serv, slot-name, item ,respond) !->
      after-favorite = !->
        respond { result: \ok, favorited: true }

      after-undo-favorite = !->
        respond { result: \ok, favorited: false }

      err = !->
        respond { result: \error, reason: 'Failed to favorite item.' }
      
      client = ConnectionManager.get-connection serv, slot-name

      if item.favorited
        client.handle-undo-favorite item.id, after-undo-favorite, err
      else
        client.handle-favorite item.id, after-favorite, err

    repost-item: (serv, slot-name, item ,respond) !->
      after-repost = !->
        respond { result: \ok, resposted: true, item: item }

      after-undo-repost = !->
        respond { result: \ok, resposted: false, item: item }

      err = !->
        respond { result: \error, reason: 'Failed to repost item.' }
      
      client = ConnectionManager.get-connection serv, slot-name

      if item.favorited
        client.handle-undo-repost item.id, after-undo-favorite, err
      else
        client.handle-repost item.id, after-favorite, err

    delete-item: (serv, slot-name, item, respond) !->
      after-delete = !->
        respond { result: \ok}

      err = !->
      
      client = ConnectionManager.get-connection serv, slot-name
      client.handle-delete item.id, after-delete, err

    # preview-media: (a-media) !->
    #   opts = {}
    #   DialogService.open-preview-dialog opts, a-media

    drop: (content, respond) !~>
      after-messager-result = !->

      err = !->
        Logger.info 'Failed to post message, save as draft'

    update-profile: (content, respond) !~>
      after-update-profile = (a-profile) !->
        account = content.account
        SliderService.update-slot-profile account.serv, account.name, a-profile
        respond { result: \ok, profile: a-profile }

      err = !->
        Logger.info 'Failed to update profile'

      if content.account
        account = content.account

        connection = ConnectionManager.get-connection account.serv, account.name
        if connection
          connection.handle-update-profile content.profile, after-update-profile, err
        else
          Logger.info 'connection is not available'

    update-avatar: (content, respond) !->
      after-update-avatar = (a-profile) !->
        account = content.account
        # WARKAROUND: twitter responds the profile with old avatar url
        connection.verify( (updated-profile) !->
          SliderService.update-slot-avatar account.serv, account.name, updated-profile.avatar-url
          SliderService.update-slot-profile account.serv, account.name updated-profile
          respond { result: \ok, profile: updated-profile }
        , !->
          respond { result: \ok, profile: a-profile }
        )

      err = !->
        Logger.info 'Failed to update profile'

      if content.account
        acount = content.account

        connection = ConnectionService.get-connection account.serv, account.name
        if connection
          content.avatar.data = Hotcake.data-URL2-uint8-array content.avatar.base64-data
          connection.handle-update-avatar content.avatar, after-update-avatar, err
        else
          Logger.info 'connection is not available'

    share-media: (a-media, respond) !->
      DialogService.open-compose-dialog SliderService.current-slot, {}, a-media

    get-OAuth-authorize-URL: (serv, user-name, respond) !->
      proto = ConnectionManager.get-proto serv
      connection = ConnectionManager.create-connection serv, user-name

      if connection
        url = connection.get-authorize-URL()

        if url
          respond { result: \ok, content: { url: url } }
        else
          respond { result: \error, reason: 'Failed to get Authrorize URL..' }
      else
        respond { result: \error, reason: 'Failed to create connection.' }

    auth-pass-proc: (serv, user-name, password, a-proto, a-connection) !->
      settings = {}

      angular.extend settings, a-proto.get-settings()

      slot = HotcakeSlot.build-defaults serv, user-name
      slot.auth-type = connection.auth-type
      slot.password = if connection.auth-type is \oauth then '' else password
      slot.access-token = connection.access-token
      slot.key = connection.key
      slot.secret = connection.secret
      slot.columns = []
      slot.settings = settings
      SliderService.add-slot slot

    authorize-with-pin: (serv, user-name, password, pin, respond) !->
      check-connection = (a-proto, a-connection) !->
        if HotcakeBus.stop-auth
          respond { result: \canceled, reason: '' }
          HotcakeBus.stop-auth = false
          return

        console.log 'check connection'

        set-timeout(
          !->
            switch a-connection.state
              when 0
                check-connection a-proto, a-connection
              when 1
                HotcakeSlot.exists serv, user-name, (result) !->
                  if result
                    respond { result: \error, reason: 'Account already exists.' }
                  else
                    HotcakeBus.auth-pass-proc serv, user-name, password, a-proto, a-connection
                    respond { result: \ok }
              default
                respond { result: \error, reason: "Failed to add acount, reson: #{a-connection.err}" }
        , 3000
        )

      HotcakeSlot.exists serv, user-name, (result) !->
        if result
          respond { result: \error, reason: 'Account already exists.' }
        else
          a-proto      = ConnectionManager.get-proto serv
          a-connection = ConnectionManager.create-connection serv, user-name
          if a-connection
            a-connection.authorize-pin pin
            check-connection a-proto, a-connection
          else
            respond { result: \error, reason: 'Failed to create connection.' }

    authorize: (serv, user-name, password, respond) !->
      check-connection = (a-proto, a-connection) !->
        if HotcakeBus.stop-auth
          respond { result: \canceled, reason: '' }
          HotcakeBus.stop-auth = false
          return

        console.log 'check connection'

        set-timeout(
          !->
            switch a-connection.state
              when 0
                check-connection a-proto, a-connection
              when 1
                HotcakeSlot.exists serv, user-name, (result) !->
                  if result
                    respond { result: \error, reason: 'Account already exists.' }
                  else
                    HotcakeBus.auth-pass-proc serv, user-name, password, a-proto, a-connection
                    respond { result: \ok }
              default
                respond { result: \error, reason: "Failed to add acount, reson: #{a-connection.err}" }
        , 3000
        )

      HotcakeSlot.exists serv, user-name, (result) !->
        if result
          respond { result: \error, reason: 'Account already exists.' }
        else
          a-proto      = ConnectionManager.get-proto serv
          a-connection = ConnectionManager.create-connection serv, user-name
          if a-connection
            a-connection.authorize user-name, password
            check-connection a-proto, a-connection
          else
            respond { result: \error, reason: 'Failed to create connection.' }

  HotcakeBus
] )
