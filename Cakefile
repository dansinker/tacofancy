FS   = require 'fs'
glob = require 'glob'

task 'build:ingredients', 'build an ingredient index.', () ->
  # Find all markdown files in the repository.
  glob '**/*.md', {}, (error, files) ->
    is_ingredient = (line) ->
      line.match /^\*\s+/i
      
    parse_ingredient = (line) ->
      line.match(/^(\*\s+)([^\n]+)$/)[2]
      
    extract_ingredients_from = (path) ->
      contents = (FS.readFileSync path, { encoding: 'utf8' }).split("\n")
      contents.shift while contents[0].match /^\s+$/
      lines = (line for line in contents when is_ingredient line )
      #console.log lines.length
      ingredients = (parse_ingredient(line) for line in lines)
      #console.log(ingredients.length)
      #console.log('"',contents[0],'"')
      name = contents[0].match(/^(\s*#+\s*)?([^\n]+)$/)?[2]
      { path: path, ingredients: ingredients, name: name }
    
    make_index = (recipes) ->
      index = {}
      #console.log(recipes)
      for recipe in recipes
        do (recipe) ->
          #console.log(recipe)
          if recipe.ingredients
            for ingredient in recipe.ingredients
              do (ingredient) -> 
                #console.log(ingredient)
                index[ingredient] ||= []
                index[ingredient].push { name: recipe.name, path: recipe.path }
      index
          
    template_index = (index) ->
      #console.log(index)
      sections = for ingredient, recipes of index
        path_list = ("* [#{recipe.name}](#{recipe.path})" for recipe in recipes).join('\n')
        "## #{ingredient}\n\n#{path_list}\n"
      "# Recipes listed by Ingredient\n\n#{sections.join "\n"}"
    
    console.log('generating ingredient index...')
    ingredients = make_index(extract_ingredients_from(file) for file in files when not file.match /(readme|index).md$/i)
    FS.writeFile 'IngredientIndex.md', template_index(ingredients)
    console.log('completed')