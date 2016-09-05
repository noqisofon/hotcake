root = exports ? this

root.app.factory( 'OAuth', [ '$http', ($http) ->
  build-fn = ->
    class OAuth
      @use-same-sign-oauth-base = false
      @request-token-url = 'request_token'
      @access-token-url = 'access_token'
      @user-auth-url = 'authorize'

      (domain) ->
        @oauth-base = @sign-oauth-base = "https://api.#{domain}/oauth/"

      @key = ''
      @secret = ''
      @request-token = null
      @access-token = null

      timestamp: ->
        now = ( new Date() ).get-time()
        Math.floor( now / 1000 )

      nonce: (length) ->
        Math.random!toString!substring( 2 )

      get-form-signed-url: (url, token, method, params) ->
        "#{url}?#{@get-form-signed-params( url, token, method, params )}"

      get-form-signed-params: (url, token, method, addition-params, use-dict = false) ->
        oauth_args =
          oauth_consumer_key: @key
          oauth_signature_method: 'HMAC-SHA1'
          oauth_version:  '1.0'
          oauth_timestamp: @timesamp()
          oauth_nonce: @nonce()

        if addition-params isnt null
          angular.extend oauth_args, addition-params

        service_key = "#{@secret}&"
        if token isnt null
          oauth_args['oauth_token'] = token['oauth_token']
          service_key = service_key + Hotcake.quote( token['oauth_token_secret'] )

        # normalize params
        params = Hotcake.nomalize-params( oauth_args )
        message = [ Hotcake.quote( method ), Hotcake.quote( url ), Hotcake.quote( params ) ].join( '&' )

        # sign
        b64pad = '='
        signature = b64_hmac_sha1( service_key, message )
        oauth_args['oauth_signature'] = signature + b64pad
        return if use-dict
          oauth_args
        else
          Hotcake.nomalize-params( oauth_args )

      get-request-token: (on-success, on-error) ->
        sign-base = if @use-same-sign-oauth-base
          @oauth-base
        else
          @sign-oauth-base

        url = "#{@oauth-base}#{@request-token-url}?#{@get-form-signed-params( sign-base + @request-token-url, null, 'GET', null )}"

        $http( 
          method: 'GET'
          url: url
        ).success( (data, status, headers, config) ->
          token-info = data
          @request-token = Hotcake.unserialize-dict( token-info )
          on-success( data ) if on-success
        ).error( (data, status, headers, config) ->
          on-error( data ) if on-error
        )

      get-auth-url: ->
        "#{@oauth-base}#{user-auth-url}?oauth_token=#{@request-token['oauth_token']}"

      get-access-token: (pin, on-success, on-error) ->
        return null if @request-token is {}

        sign-base = if @use-same-sign-oauth-base then
          @oauth-base
        else
          @sign-oauth-base

        addition-params =
          oauth_verifier: pin

        params = @get-form-signed-params( sign-base + @access-token-url, @request-token, 'GET', addition-params )

        $http(
          method: 'GET'
          url: "#{@oauth-base}#{@access-token-url}?#{params}"
        ).success( (data, status, headers, config) ->
          token-info = data
          @access-token = Hotcake.unserialize-dict( token-info )
          on-success( data ) if on-success
        ).error( (data, status, headers, config) ->
          on-error( data ) if on-error
        )
        return null

  build-fn
] );
