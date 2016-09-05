root = exports ? this

root.app.controller( 'WindowCtrl', [ '$scope', 'SettingService', 'Logger',
($scope, SettingService, Logger) !->
  holding = false
  current-window = null
  offset-x = 0
  offset-y = 0

  $scope.has-focus = true
  $scope.title-bar-cls = ''

  root.on-focus = ->
    $scope.$apply ->
      $scope.has-focus = true

  root.on-blur = ->
    $scope.$apply ->
      $scope.has-focus = false

  $scope.init-win-ctrl = !->
    check-os = os ->
      if os === 'osx' then
        'osx'
      else
        'other'

    set-timeout( ->
      theme = SettingsService.get-forbiddens( 'theme' )
      current-window = Hotcake.window.current()

      os = Hotcake.detect-OS()

      $scope.title-bar-cls = switch theme
        when 'osx', 'other'
          theme
        default
          check-os( os )
          
    , 1000 )

  $scope.get-title-bar-cls = ->
    if not $scope.has-focus then
      "#{$scope.title-bar-cls} lose_focus"
    else
      "#{$scope.title-bar-cls} "

  $scope.minimize-window = !->
    current-window.minimize()

  $scope.normalize-window = !->
    if current-window.is-maximize() then
      current-window.restore()
    else
      current-window.maximize()

  $scope.close-window = !->
    current-window.close()

  $scope.fullscreen-window = !->
    current-window.fullscreen()
] )
