class AbsColumn
  load-feature-pix: (item) !->
    Hotcake.fetch-image item.feature-pic-url, (data) !->
      $scope.$apply !->
        item.feature-pic-data = window.webkit-URL.create-object-URL( data )

root = exports ? this
this.AbsColumn = AbsColumn
