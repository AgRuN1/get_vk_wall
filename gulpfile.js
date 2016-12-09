let gulp = require('gulp'),
	$ = require('gulp-load-plugins')(),
	browser = require('browser-sync');

const jslibs = [
    'app/libs/jquery/dist/jquery.min.js',
    'app/libs/angular/angular.min.js',
    'app/libs/bootstrap/dist/js/bootstrap.min.js',
    'app/libs/angular-animate/angular-animate.min.js'
];

const csslibs = [
    'app/libs/bootstrap/dist/css/bootstrap.min.css',
    'app/libs/bootstrap/dist/css/bootstrap-theme.min.css'
];

const path = {
	bem:{
		js: 'app/bem/**/*.js',
		stylus: 'app/bem/**/*.styl'
	},
	source:{
		stylus: 'app/stylus/**/*.styl',
		coffee: 'app/coffee/**/*.coffee',
		fonts: 'app/fonts/**/*',
		img: 'app/img/**/*',
        html: 'app/**/*.html',
        babel: 'app/babel/**/*.js'
	},
	build:{
		js: 'app/js/',
		css: 'app/css/'	
	},
    libs: 'app/libs'
};

let options = {
	server:{
			baseDir: 'app/'
		},
		host: 'localhost',
		port: 9000,
		notify:false
};

gulp.task('browser',()=>{
	browser(options);
});

gulp.task('stylus',()=>{
	return gulp.src(path.source.stylus)
		.pipe($.stylus().on('error',$.notify.onError({
            message: "<%= error.message %>",
            title: 'Stylus error'
        })))
		.pipe($.postcss([
			require('autoprefixer')
		]))
		.pipe($.cssmin())
		.pipe(gulp.dest(path.build.css))
        .pipe(browser.reload({stream:true}))
});

gulp.task('babel', ()=>{
   return gulp.src(path.source.babel) 
        .pipe($.babel({
            presets: ['es2015']
        }))
        .pipe($.uglify({mangle: false}))
        .pipe(gulp.dest(path.build.js))
        .pipe(browser.reload({stream: true}));
});

gulp.task('coffee', ()=>{
	return gulp.src(path.source.coffee)
		.pipe($.coffee().on('error',$.notify.onError({
            message: "<%= error.stack %>",
            title: 'Coffee error'
        })))
		.pipe($.uglify({ mangle: false }))
		.pipe(gulp.dest(path.build.js))
        .pipe(browser.reload({stream:true}));
});

gulp.task('watch', ()=>{
	gulp.watch(path.source.stylus,['stylus']);
	gulp.watch(path.source.coffee,['coffee']);
	gulp.watch(path.source.babel,['babel']);
	gulp.watch(path.source.html,browser.reload);

});

gulp.task('jslibs', function(){
    return gulp.src(jslibs)
        .pipe($.concat('libs.js'))
        .pipe(gulp.dest(path.build.js));
});

gulp.task('csslibs', function(){
    return gulp.src(csslibs)
        .pipe($.concat('libs.css'))
        .pipe(gulp.dest(path.build.css));
});

gulp.task('default',['watch','browser'],()=>{

});