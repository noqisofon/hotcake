
dynamic-type-names = <[ search people list ]>

object-array-p = (that) ->
  that.constructor is Object of that.constructor is Array

root = exports ? this

root.app.factory( 'ProtoTwitter', [ '$http', 'Proto', 'OAuth1', 'HotcakeCache', 'Logger', ($http, Proto, OAuth1, HotcakeCache, Logger) ->
  build-fn = ->
    build-fn.message-update-interval = 300
    build-fn.support-message = true

    build-fn.get-default-column-types = ->
      ret =
        * type: 'home'
          singleton: true
          params: []
        * type: 'mention'
          singleton: true
          params: []

    build-fn.build-column = (type, slot-name, params) ->
      if default-column-book.hasOwnProperty( type )
        cc = {}
        angular.extend( cc, default-column-book[type] )
        cc.slot_name = slot-name

        if params
          cc.params = params
        if dynamic-type-names.index-of( type ) isnt -1
          cc.name  = "#{type}:#{Hotcake.generateUUID()}"
          cc.title = "#{cc.title}:#{params.join( '/' )}"
        else     # singleton
          cc.name = type
        cc.name = cc.name.to-lower-case()
        return cc
      null

    build-fn.formalize-column = (col) ->
      if default-column-book.hasOwnProperty( type )
        tmp-col = default-column-book[col.type]
        col.display_name = tmp-col.display_name
        col.title = tmp-col.title
        col.icon_name = tmp-col.icon_name
        col.mute = [] if typeof col.mute is undefined
      col

    build-fn.get-settings = ->
      {}

    build-fn.get-column-position-mode = (name) ->
      return switch name
        when 'home'
          fallthrough
        when 'mention'
          fallthrough
        when 'incoming_messeage'
          fallthrough
        when 'sent_message'
          'id'
        when 'search'
          'external_id'
        default
        'id'

    class ProtoTwitter
      @state = 0
      @screen-name = ''
      @name = 'twitter'
      @display-name = 'twitter'
      @auth-type = 'oath'
      @http-base = 'https://twitter.com/'
      @api-base = 'https://api.twitter.com/1.1/'
      @sign-api-base = 'https://api.twitter.com/1.1/'
      @search-api-base = 'https://twitter.com/phoenix_search.phoenix/'
      @upload-api-base = 'https://upload.twitter.com/1.1/'
      @key = 'INPUT YOUR ACCESS KEY'
      @secret = 'INPUT YOUR ACCESS KEY SECRET'
      @oauth = new OAuth()
      @oauth.key = @key
      @oauth.secret = @secret
      @access-token = null
      @support-stream = true
      @support-sub-stream =
        home: true
        menthion: true
        message: true

      config: (slot) !->
        @screen-name = slot.name
        @access-token = slot.access-token
        @key = @oauth.key = slot.key
        @secret = @oauth.secret =  slot.secret
    
    ProtoTwitter
  build-fn
] )
