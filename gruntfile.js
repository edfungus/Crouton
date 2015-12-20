module.exports = function(grunt) {
  require('jit-grunt')(grunt);

  grunt.initConfig({
    less: {
      development: {
        options: {
          compress: true,
          yuicompress: true,
          optimization: 2
        },
        files: [{
          expand: true,
          src: ['public/app/framework/**/*.less','public/app/dashboard-elements/**/*.less','public/app/documentation/*.less','public/common/css/*.less'],
          ext: '.css',
          extDot: 'first'
        }]
      }
    },
    watch: {
      styles: {
        files: ['public/app/framework/**/*.less','public/app/dashboard-elements/**/*.less','public/app/documentation/*.less','public/common/css/**/*.less'], // which files to watch
        tasks: ['less'],
        options: {
          nospawn: true
        }
      }
    }
  });

  grunt.registerTask('default', ['less', 'watch']);
  grunt.registerTask('prod', ['less']);
};
