FS   = require 'fs'
glob = require 'glob'

task 'build:ingredients', 'build an ingredient index.', () ->
  console.log('generating ingredient index...')
  # Find all markdown files in the repository.
  glob '**/*.md', {}, (error, files) ->
    is_ingredient = (line) ->
      line.match /^\*\s+/i
      
    parse_ingredient = (line) ->
      
      
    extract_ingredients_from = (path) ->
      #console.log "Extracting from:", path
      contents = FS.readFileSync path, { encoding: 'utf8' }
      lines = (line for line in contents.split '\n' when is_ingredient line )
      #console.log lines.length
      [path, lines]
    
    make_index = (pairs) ->
      index = {}
      #console.log pairs
      for pair in pairs
        do (pair) ->
          [path, lines] = pair
          #console.log(path)
          for line in lines
            do (line) -> 
              index[line] ||= []
              index[line].push path
      index
          
    template_index = (index) ->
      sections = for ingredient, paths of index
        path_list = ("* #{path}" for path in paths).join('\n')
        "## #{ingredient}\n\n#{path_list}\n"
      "# Recipes listed by Ingredient\n\n#{sections.join "\n"}"
    
    ingredients = make_index(extract_ingredients_from(file) for file in files when not file.match /(readme|index).md$/i)
    FS.writeFile 'IngredientIndex.md', template_index(ingredients)
    console.log('completed')