FS   = require 'fs'
glob = require 'glob'

task 'build:ingredients', 'build an ingredient index.', () ->
  # Find all markdown files in the repository.
  glob '**/*.md', {}, (error, files) ->
    ingredients = {}

    is_ingredient = (line) ->
      line.match /^\*\s+/i
      
    extract_ingredients_from = (path) ->
      unless path.match /(readme|index).md$/i
        console.log "Extracting from:", path
        contents = FS.readFileSync path, { encoding: 'utf8' }
        lines = (line for line in contents.split '\n' when is_ingredient line )
        console.log lines.length
        lines
    
    lines = (extract_ingredients_from file for file in files)
    console.log lines
