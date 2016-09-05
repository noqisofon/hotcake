root = exports ? this

root.app = angular.module( 'hotcakeApp', [ 'ngSanitize' ], [ '$httpProvider', ($http-provide) ->
  $http-provide.defaults.headers.post['Content-Type'] = 'application/x-www-form-urlencoded;charset=utf-8'

  $http-provide.defaults.transform-request = [
    (data) ->
      param = (obj) ->
        query = []
        for name, value of obj
          if value isnt undefined and value isnt null
            query.push Hotcake.query( name ) + '=' + Hotcake.quote( value )
          return query.join( '&' )
        
      ret = if data and data.constructor is Object    # don't use angular.isObject
        param( data )
      else
        data
      return if ret is undefined
        ''
      else
        ret
    ]
] )

bind-directive( root.app, [ 'KEY', 'MISC', 'MOUSE', 'ANI', 'SCROLL', 'DMD' ] )

root.app.run( [ 'HotcakeSlot', 'HotcakeColumn', 'HotcakeBus', 'ConnectionManager', 'ProtoTwitter', 'MessageService', 'SettingService', 'RelationService', 'SliderService',
(HotcakeSlot, HotcakeColumn, HotcakeBus, ConnectionManager, ProtoTwitter, MessageService, SettingService, RelationService, SliderService) !->
  HotcakeBus.init()
  HotcakeSlot.init()
  HotcakeColumn.init()

  ConnectionManager.add-proto( 'twitter', ProtoTwitter )
  ConnectionManager.init()

  MessageService.init()
  SettingService.init()
  RelationService.init()
  SliderService.init()
] )
