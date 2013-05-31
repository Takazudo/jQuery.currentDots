module.exports = (grunt) ->
  
  grunt.task.loadTasks 'gruntcomponents/tasks'
  grunt.task.loadNpmTasks 'grunt-contrib-coffee'
  grunt.task.loadNpmTasks 'grunt-contrib-watch'
  grunt.task.loadNpmTasks 'grunt-contrib-concat'
  grunt.task.loadNpmTasks 'grunt-contrib-uglify'

  grunt.initConfig

    pkg: grunt.file.readJSON('package.json')
    banner: """
/*! <%= pkg.name %> (<%= pkg.repository.url %>)
 * lastupdate: <%= grunt.template.today("yyyy-mm-dd") %>
 * version: <%= pkg.version %>
 * author: <%= pkg.author %>
 * License: MIT */

"""

    growl:

      ok:
        title: 'COMPLETE!!'
        msg: '＼(^o^)／'

    coffee:

      currentdots:
        src: [ 'jquery.currentdots.coffee' ]
        dest: 'jquery.currentdots.js'

    concat:

      banner:
        options:
          banner: '<%= banner %>'
        src: [ '<%= coffee.currentdots.dest %>' ]
        dest: '<%= coffee.currentdots.dest %>'
        
    uglify:

      options:
        banner: '<%= banner %>'
      currentdots:
        src: '<%= concat.banner.dest %>'
        dest: 'jquery.currentdots.min.js'

    watch:

      currentdots:
        files: '<%= coffee.currentdots.src %>'
        tasks: [
          'default'
        ]

  grunt.registerTask 'default', [
    'coffee'
    'concat'
    'uglify'
    'growl:ok'
  ]

