"use strict";

gulp       = require "gulp"
gutil      = require "gulp-util"
sourcemaps = require "gulp-sourcemaps"
watchify   = require "watchify"
browserify = require "browserify"
source     = require "vinyl-source-stream"
buffer     = require "vinyl-buffer"
_          = require "lodash"

onError = gutil.log.bind gutil, gutil.colors.red("Browserify Error:")
onUpdateLog = gutil.log.bind gutil, "changed files: "

browserifyOpts =
    extensions: [".jsx", ".js"]
    debug: true
    cache: {}
    packageCache: {}
    fullPaths: true

srcIndexPath = "./node_modules/app/index.js"

jsLibs = () ->
    browserify(["react"], {debug: true})
        .require("react")
        .require("react/addons")
        .require("react-router-component")
        .require("lodash")
        .bundle()
        .pipe source "libs.js"
        .pipe gulp.dest "./js/"

makeRebundle = (bundler) ->
    () ->
        bundler
            .bundle()
            .on "error", onError
            .pipe source("index.js")
            .pipe buffer()
            .pipe sourcemaps.init({loadMaps: true})
            .pipe sourcemaps.write()
            .pipe gulp.dest("./js")

js = () ->
    jsLibs()

    browserify srcIndexPath, browserifyOpts
        .transform "reactify", {everything: true, harmony: true}
        .external "react"
        .external "react/addons"
        .external "react-router-component"
        .external "lodash"
        .bundle()
        .on "error", onError
        .pipe source("index.js")
        .pipe buffer()
        .pipe sourcemaps.init({loadMaps: true})
        .pipe sourcemaps.write()
        .pipe gulp.dest("./js")


watch = () ->
    bundler = watchify browserify(srcIndexPath, browserifyOpts)
        .transform "reactify", {everything: true, harmony: true}
        .external "react"
        .external "react/addons"
        .external "react-router-component"
        .external "lodash"

    reubundel = makeRebundle bundler

    bundler
        .on "update", reubundel
        .on "update", onUpdateLog
        .on "log", gutil.log

    jsLibs()
    reubundel()


gulp.task "js", js
gulp.task "watch", watch
