module.exports = function(grunt) {
  require('jit-grunt')(grunt);
  grunt.loadNpmTasks('grunt-contrib-pug');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-sync');
  grunt.loadNpmTasks('grunt-contrib-connect');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.initConfig({
    less: {
      development: {
        options: {
          compress: true,
          yuicompress: true,
          optimization: 2
        },
        files: [
          {
            expand: true,
            flatten: true,
            cwd: 'public/',
            dest: 'build/css',
            src: [
              'app/framework/**/*.less',
              'app/dashboard-elements/**/*.less',
              'app/documentation/*.less',
              'common/css/*.less'
            ],
            ext: '.css',
            extDot: 'first'
          }
        ]
      }
    },
    pug: {
      compile: {
        options: {
          pretty: true,
          data: require('./static-paths.js')
        },
        files: [
          {
            expand: true,
            flatten: true,
            cwd: 'public/app',      // Src matches are relative to this path.
            src: ['**/*.pug'], // Actual pattern(s) to match.
            dest: 'build/html',   // Destination path prefix.
            ext: '.html',   // Dest filepaths will have this extension.
            extDot: 'first'   // Extensions in filenames begin after the first dot
          }
        ]
      }
    },
    sync: {
      main: {
        files: [
          {
            expand: true,
            cwd: 'public/common',
            flatten: true,
            src: [
              'bower/webcomponentsjs/*.js',
              'bower/packery/dist/*.min.js',
              'bower/draggabilly/dist/*.min.js',
              'bower/jquery/dist/*.min.js',
              'bower/chartist/dist/*.min.js',
              'js/*',
            ],
            dest: 'build/js/'
          },
          {
            expand: true,
            cwd: 'public/app/documentation',
            flatten: true,
            src: [
              '*.js',
            ],
            dest: 'build/js/'
          },
          {
            expand: true,
            cwd: 'public/app/documentation',
            flatten: true,
            src: [
              '*.css',
            ],
            dest: 'build/css/'
          },
          {
            expand: true,
            cwd: 'public/app/documentation',
            flatten: true,
            src: [
              '*.md',
            ],
            dest: 'build/'
          },
          {
            expand: true,
            cwd: 'public/common',
            flatten: true,
            src: [
              'bower/chartist/dist/*.min.css',
              'bower/font-awesome/css/*.min.css',
            ],
            dest: 'build/css/'
          },
          {
            expand: true,
            cwd: 'public/common',
            flatten: true,
            src: [
              'images/*'
            ],
            dest: 'build/images/'
          },
          {
            expand: true,
            cwd: 'public/common',
            flatten: true,
            src: [
              'bower/Materialize/fonts/roboto/*',
              'bower/font-awesome/fonts/*',
            ],
            dest: 'build/fonts/'
          },
          {
            expand: true,
            cwd: 'build/html',
            src: [
              'index.html'
            ],
            dest: 'build/'
          },
          {
            expand: true,
            cwd: 'public/common/bower',
            src: [
              '**/*'
            ],
            dest: 'build/static/common/bower'
          }
        ]
      }
    },
    clean: [
      'build/html/index.html'
    ],
    connect: {
      server: {
        options: {
          port: 9000,
          base: 'build'//,
          //keepalive : true
        }
      }
    },
    watch: {
      styles: {
        files: [
          'public/**/*'
        ],
        tasks: ['less', 'pug', 'sync', 'clean'],
        options: {
          livereload: true,
          nospawn: true
        }
      },
      options: {
			  interval: 2000
		  }
    }
  });

  grunt.registerTask('default', ['less', 'pug', 'sync', 'clean', 'connect', 'watch']);
};
