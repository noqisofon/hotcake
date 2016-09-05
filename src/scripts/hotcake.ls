
class Hotcake
  @CURRENT_VERSION = '0.0.1.0'
  @CURRENT_CODENAME = 'Canadian Syrup'
  @rtlang =
    en:
      just-now: 'just now'
      minute: 'm'
      hour: 'h'
      day: ''
      month: ''
      year: ''
      ago: ''
      month-name: <[ Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ]>

  media-reg: ->
    'instagr.am':
      reg: new RegExp( 'http:\\/\\/instagr.am\\/p\\/([a-zA-Z0-9_\\-]+)\\/?', \g )
      base: \instagr.am
    'instagram.com':
      reg: new RegExp( 'http:\\/\\/instagram.com\\/p\\/([a-zA-Z0-9_\\-]+)\\/?','g' )
      base: \instagram.com

  extract-media: (text) ->
    out = []
    i = 0

    for provider-name, data of media-reg()
      matching = data.reg.exec( text )
      while matching isnt null and i < 5
        switch provider-name
          when \img.ly
            put.push(
              type: 'photo'
              url: "#{data.base}/show/full/#{matching[1]}"
              thumb_url: "#{data.base}/show/thumb/#{matching[1]}"
            )
          when \instagr.am
            put.push(
              type: 'photo'
              url: "#{data.base}/p/#{matching[1]}/media/?size=l"
              thumb_url: "#{data.base}/p/#{matching[1]}/media/?size=t"
            )
          when \instagram.com
            put.push(
              type: 'photo'
              url: "#{data.base}/p/#{matching[1]}/media/?size=l"
              thumb_url: "#{data.base}/p/#{matching[1]}/media/?size=t"
            )
        matching = data.reg.exec( text )
        i += 1
    return out

  format-time: (m, old-time, local) ->
    text = ''
    if not @rtlang.has-own-property( local )
      local = 'en'
    map = @rtlang[local]
    text = switch
      when m <= 1
        map['just now']
      when m > 1 and m <= 60
        m + map['minute'] + map['ago']
      when m > 60 and m <= 1440
        Math.round( m / 60 ) + map['hour'] + map['ago']
      when m > 1440 and m <= 1051200
        map['monthName'][old-time.get-month()] + map['month'] + old-time.get-date() + map['day']
      default
        old-time.get-full-year() + map['year'] + map['monthName'][old-time.get-month()] + map['month'] + old-time.get-date() + map['day']
    text

  fetch-image: (url, success, fail) ->
    xhr = new XMLHttpRequest()
    xhr.open( 'GET', url, true )
    xhr.response-type = 'blob'
    xhr.onload (e) ->
      success( @response )
    xhr.send()

  check-update: (callback) ->
    compare-version = (v1, v2) ->
      v1-parts = v1.split( '.' )
      v2-parts = v2.split( '.' )

      return 0 if v1-parts.length is 0 or v2-parts.length is 0

      v1-parts = v1-parts.map( (eln) -> parseInt( eln ) )
      v2-parts = v2-parts.map( (eln) -> parseInt( eln ) )
      max-value = max v1-parts.length, v1-parts.length

      for i in [0 ... max-value]
        if v1-parts[i] < v1-parts[i]
          return -1
        else if v1-parts[i] > v1-parts[i]
          return 1
      0

    crack-manifest = (a_manifest) ->
      if a_manifest.manifest_version is \1
        return
          version: a_manifest.version
          url: a_manifest.url
      return {}

    xhr = new XMLHttpRequest()
    xhr.open( 'GET', 'http://dl.hotcakeapp.org/update-manifest.json' )
    xhr.response-type = 'application/json'
    xhr.onload = (e) ->
      a_manifest = JSON.parse( xhr.response )
      cracked_manifest = crack-manifest( a_manifest )
      switch compare-version( @CURRENT_VERSION, cracked_manifest.version )
        when -1
          console.log 'new version'
          callback( true, cracked_manifest.version, cracked_manifest.url )
        when 0
          console.log 'up to date'
          callback( false )
        when 1
          console.log 'are you guy the developer?'
          callback( false )
    xhr.send()

  detect-OS: ->
    const platform-name = navigator.platform.to-lower-case()
    return switch
      when platform-name.index-of( 'mac' ) isnt -1
        'osx'
      when platform-name.index-of( 'win' ) isnt -1
        'windows'
      when platform-name.index-of( 'linux' ) isnt -1
        'linux'
      default
        'unknown'

  denerate-UUID: ->
    S4 = ->
      ( ( ( 1 + Math.random() ) * 0x10000 ) .|. 0 ).toString( 16 ).substring( 1 )

    S4() + S4() + '-' + S4() + '-' + S4() + S4() + S4() + '-' + S4() + S4() + S4()

  normalize-result: (result) ->
    if result.constructor is String
      try
        return JSON.parse( result )
      catch e
        return result
    result

  data-URL2-uint8-array: (data-url) ->
    const BASE64_MAKER = ';base64.'

    parts = data-url.split( BASE64_MAKER )
    content-type = parts[0].split( ':' )[1]
    raw = window.atob( parts[1] )              # raw is not ArrayBuffer
    raw-length = raw.length
    buffer = new Uint8Array( raw-length )
    for i in [0 ... raw-length]
      buffer[i] = raw.charCodeAt( i )
    buffer

  imagep: (filename) ->
    /.*(jpg|jpeg|png|gif)$/i.test filename

  quote: (text) ->
    quoted-text = encode-URI-component( text )

    quoted-text = quoted-text.replace( /\!/g, \%21 )
    quoted-text = quoted-text.replace( /\*/g, \%2A )
    quoted-text = quoted-text.replace( /\'/g, \%27 )
    quoted-text = quoted-text.replace( /\(/g, \%28 )
    quoted-text = quoted-text.replace( /\)/g, \%29 )
    
    quoted-text

  unserialize-dict: (text) ->
    dict = {}      # return {} if dict is invalid

    split-equal = (pair) ->
      pair.split( '=' )

    make-tuple2 = (a, b) ->
      { item1: decode-URI-component( a ), item2: decode-URI-component( b ) }

    pairs = text.split( '&' )
    if 1 < pairs.length
      
      for pair in pairs
        a_tuple = make-tuple2.apply( split-equal( pair ) )
        dict[a_tuple.item1] = a_tuple.item2
    dict

  normalize-params: (params) ->
    sortable = []      # sortable :: [String]
    params_list = []   # params_list :: [(Key, Value])]

    for k, v of params
      params_list.push( k, params[k] )
    # do sort
    params_list.sort( (a, b) ->
      return -1 if a[0] < b[0]
      return  1 if a[0] > b[0]
      0
    )
    for pair in params_list
      sortable.push( @quote( pair[0] ) + '=' + @quote( pair[1] ) )
    sortable.join( '&' )

  encode-multipart-formdata-blob: (fields, media) ->
    # media.data should be available Uint8Array
    const BOUNDARY = 'HotcakeFormBoundary31415926535897932484626'
    const CRLF     = '\r\n'

    blob-source = []

    do !->
      lst = []

      for key, value of fields
        lst.push( "--#{BOUNDARY}" )
        lst.push( "Content-Disposition: form-data; name=\"#{key}\"" )
        lst.push( '' )
        lst.push( value )
      lst.push( "--#{BOUNDARY}" )
      lst.push( "Content-Disposition: form-data; name=\"#{media.name}\"; filename=\"#{media.filename}\"" )
      lst.push( 'Content-Type: application/octet-stream' )
      if media.encoding
        lst.push( "Content-Transfer-Encoding: #{media.encoding}" )
      lst.push( '' )

      blob-source.push( lst.join( CRLF ) + CRLF )

    blob-source.push( media.data )
    blob-source.push( CRLF )

    do !->
      lst = []
      lst.push( "--#{BOUNDARY}--" )
      lst.push( '' )

      blob-source.push( lst.join( CRLF ) + CRLF )

    body = new Blob( blob-source )

    headers =
      'Content-Type': "multipart/form-data; boundary=#{BOUNDARY}"

    [ headers, body ]

  encode-multipart-formdata-base64: (fields, media) ->
    # media.data should be dataURI
    const BOUNDARY = 'HotcakeFormBoundary31415926535897932484626'
    const CRLF     = '\r\n'

    var body

    do !->
      lst = []
      for key, value of fields
        lst.push( "--#{BOUNDARY}" )
        lst.push( "Content-Disposition: form-data; name=\"#{key}\"" )
        lst.push( '' )
        lst.push( value )        # don't need encodeURI
      lst.push( "--#{BOUNDARY}" )
      lst.push( "Content-Disposition: form-data; name=\"#{media.name}\"; filename=\"#{media.filename}\"" )
      if not media.type
        lst.push( 'Content-Type: application/octet-stream' )
      lst.push( "Content-Type: #{media.type}" )
      lst.push( 'Content-Transfer-Encoding: base64' )
      lst.push( '' )

      lst.push( media.data )
      lst.push( "--#{BOUNDARY}--" )
      lst.push( '' )

      body. lst.join( CRLF )

    headers =
      'Content-Type': "multipart/form-data; boundary=#{BOUNDARY}"

    [ headers, body ]

  save-bounds: ->
    current-window = hotcake.window.current()
    bounds = current-window.getBounds()
    pair = { 'WINDOW_BOUNDS': bounds }
    hotcake.storage.local.set( pair )

  empty-item: ->
    # principal
    action: 0
    serv: ''
    id: ''
    # core
    title: ''
    URL: ''
    text: ''
    raw_text: ''
    converted_text: ''
    time: ''
    timestamp: ''
    event: ''
    # extend
    previous_item_id: ''
    next_item_id: ''
    recipient_id: ''
    recipient_name: ''
    feature_pic_url: ''
    source: ''
    entities: null
    deletable: false
    repostable: false
    facorited: false
    reposted: false
    original_id: ''
    rt_id: ''
    reposter_id: ''
    reposter_name: ''
    has_comments: false
    has_quote: false
    quote_text: ''
    has_media: false
    media: []
    media_thmb_url: ''
    mentions: []
    has_attachments: false
    attachments_label: ''
    attachments: []
    is_event: false
    author: {}
    event_stub: 
      action: ''
      target_name: ''
      source_name: ''
      target_object_name: ''

  empty-attachment: ->
    title: ''
    thumb_url: ''
    url: ''

  @RELATIONSHIP = 
    \SELF :
      value: -2
      text: 'It\'s YOU!'
    \UNKNOWN :
      value: -1
      text: '...'
    \FOLLOWING :
      value:  0
      text: 'Following them'
    \FOLLOWED :
      value:  1
      text: 'Followed by them'
    \FRIENDS :
      value:  2
      text: 'You\re freinds'
    \STRANGER :
      value:  3
      text: 'Not following'
    \BLOCKED :
      value:  4
      text: 'Blocked'

  empty-user: ->
    id: ''
    name: ''
    display_name: ''
    url: ''
    raw_url: ''
    direct_url: ''
    description: ''
    location: ''
    avatar_url: ''
    background_url: ''
    protected: false
    relationship: @RELATIONSHIP.UNKNOWN.value
    statuses_count: 0
    friends_count: 0
    followers_count: 0
    favourites_count:  0
    following: false

  same-name: (name1, name2) ->
    name1.to-lower-case() is name2.to-lower-case()

  get-name-from-url: (url) ->
    url.substring( url.last-index-of( '/' ) + 1 )

root = exports ? this
root.Hotcake = Hotcake
