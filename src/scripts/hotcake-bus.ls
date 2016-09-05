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
      notify = (win, cmd, content, respond) ->
        if HotcakeBus.message-map.has-own-property( command )
          for callback in HotcakeBus.message-map[ command ]
            callback( win, cmd, content, respond )

      Hotcake.bus.on-message.add-listener! (message, sender, respond) ->
        # console.log \control, ev
        win = message.win
        cmd = message.cmd
        content = message.content
        # console.log 'Messagebus receives a mennsage: ', win, cmd, content
        HotcakeBus.crack win, cmd, content, respond
        notify win, cmd, content, respond
        true

    register: (command, callback) !->
      if HotcakeBus.message-map.has-own-property( command )
        HotcakeBus.message-map[command].push( callback )
      else
        HotcakeBus.message-map[command] = [ callback ]

    crack: (win, cmd, content, respond) !->
      switch cmd
        when \auth
          HotcakeBus.authorize content.serv, content.username, content.password, respond
        when \oauth_get_authorize_url
          HotcakeBus.get-OAuth-authorize-URL content.serv, content.username, respond
        when \oauth_with_pin
          HotcakeBus.authorizeWithPin content.serv, content.username, content.password, content.pin, respond
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
            Hotcake.bus.send-message(
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
      

  HotcakeBus
] )
