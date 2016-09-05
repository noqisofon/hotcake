
require! {
  gulp
  'gulp-ls': ls
  'gulp-lint-ls': lint-ls
}

gulp.task \build-src !->
  gulp.src [ './core/scripts/*.ls' ]
    .pipe ls( { bare: true } )
    .pipe gulp.dest( './core/scripts' )

gulp.task \lint-src !->
  gulp.src './core/scripts/*.ls'
    .pipe lint-ls!

gulp.task \default <[ lint-src build-src ]>
