root = exports ? this

root.app.factory( 'AppService', [ '$rootScope', ($root-scope) ->
  AppService =
    display-name: 'AppService'
    cmd: ''
    client-info:
      window:
        width: 0
        height: 0
      main:
        width: 0
        height: 0
      max-column-amount: 1
      keywords: ''

    broadcast: (command, values) ->
      this.cmd = command

      for k, v in values
        if this.has-own-property( k )
          this[k] = v

      switch command
        when \resize
          $root-scope.$broadcast 'AppResize'
        when \trigger_resize
          $root-scope.$broadcast 'AppTriggerResize'
        when \search
          $root-scope.$broadcast 'AppSearch'
        when \leave_search_mode
          $root-scope.$broadcast 'LeaveSearchMode'

  AppService
] )
