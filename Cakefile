FS   = require 'fs'
Path = require 'path'
glob = require 'glob'

spacify = (str) -> str.replace(/_/g, ' ')
capitalize = (str) -> str.charAt(0).toUpperCase() + str.substring(1).toLowerCase();

task 'build:toc', 'build a table of contents', () ->
  ignore = (file) -> file[0] is '.' or file is 'node_modules' or file.match /^readme/i

  recipe_info = (path) ->
    contents = (FS.readFileSync path, { encoding: 'utf8' }).split("\n")
    contents.shift() while contents[0].match(/^\s*$/)
    name = contents[0].match(/^(\s*#+\s*)?([^\n]+)$/)?[2]
    { name: name, path: path }
  
  section_info = (path) ->
    name = capitalize(spacify(Path.basename(path)))
    {name: name, path: path}
  
  index_dir = (base, index = {}) ->
    files = FS.readdirSync(base)
    dirs = (section_info(file) for file in files when FS.lstatSync(Path.join(base, file)).isDirectory() and not ignore(file))
    index.markdown = (recipe_info(Path.join(base, file)) for file in files when Path.extname(file).match(/md|markdown|mdown$/) and not ignore(file))
    index.subdirs = {}
    index.subdirs[section.name] = index_dir(section.path) for section in dirs
    index

  template_sections = (index, base, tabs = "") ->
    #console.log("INDEX", index)
    markup = ""
    markup += "#{ tabs }* [#{dirname}](#{dirname}/)\n#{ template_sections(subindex, dirname, tabs + "\t") }" for dirname, subindex of index.subdirs
    markup += "#{ tabs }* [#{recipe.name}](#{recipe.path})\n" for recipe in index.markdown
    markup
  
   FS.writeFile 'table_of_contents.md', template_sections(index_dir('.'))


task 'build:ingredients', 'build an ingredient index.', () ->
  # Find all markdown files in the repository.
  glob '**/*.md', {}, (error, files) ->
    is_ingredient = (line) ->
      line.match /^\*\s+/i
      
    parse_ingredient = (line) ->
      line.match(/^(\*\s+)([^\n]+)$/)[2]
      
    extract_ingredients_from = (path) ->
      contents = (FS.readFileSync path, { encoding: 'utf8' }).split("\n")
      contents.shift() while contents[0].match(/^\s*$/)
      lines = (line for line in contents when is_ingredient line )
      #console.log lines.length
      ingredients = (parse_ingredient(line) for line in lines)
      #console.log(ingredients.length)
      #console.log('"'+contents[0]+'":', contents[0].match /^\s*$/)
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
      return index
          
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
