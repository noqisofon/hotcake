this.app = angular.module 'HotcakeComposeDialog', []

this.app.controller( 'ComposeCtrl', [ '$scope', ($scope) !->
  BASE_HEIGHT      = 164
  CONTEXT_HEIGHT   =  30
  EFFECT_HEIGHT    = 50 + 6
  CANDIDATE_HEIGHT = 32 + 6

  timer = null

  in-detecting = false

  $scope.context-bar =
    height: 32
    show: false
    avatar-data: ''
    text: ''

  $scope.effects-bar =
    height: 32
    show: false
    offset: 0
    spinner-show: false
    spiner-label: 'loading'

  $scope.candidate-bar =
    show: false
    list: []

  $scope.draft-list =
    show: false
    drafts: []

  $scope.account-list =
    show: false

  effect-scroller = null
  candidate-scroller = null

  $scope.effects =
    * name: 'normal'
      icon-name: \normal
      display-name: 'Normal'
    * name: 'vintage'
      icon-name: \vintage
      display-name: 'Vintage'
    * name: 'lomo'
      icon-name: \lomo
      display-name: 'LOMO'
    * name: 'warmAutumn'
      icon-name: \autumn
      display-name: 'Autumn'
    * name: 'softenFace'
      icon-name: \beauty
      display-name: 'Beauty'
    * name: 'sketch'
      icon-name: \sketch
      display-name: 'Sketch'
    * name: 'softEnhancement'
      icon-name: \enhance
      display-name: 'Enhance'
    * name: 'purpleStyle'
      icon-name: \purple
      display-name: 'Purple'
    * name: 'soften'
      icon-name: \soften
      display-name: 'Soften'
    * name: 'gray'
      icon-name: \bw
      display-name: 'B&W'
    * name: 'strongEnhancement'
      icon-name: \lighten
      display-name: 'Lighten'
] )

bind-ditective app, <[ KEY MISC DND ]>

this.app.directive \on-autocomp, !->
  (scope, elm, attrs) !->
    fn = scope.$eval attrs.on-autocomp

    elm.bind \keydown, (evt) !->
      scope.$apply !->
        fn.call scope, evt
