FS   = require 'fs'
Path = require 'path'
glob = require 'glob'

spacify = (str) -> str.replace(/_/g, ' ')
capitalize = (str) -> str.charAt(0).toUpperCase() + str.substring(1).toLowerCase();

task 'build', 'build ALL THE THINGS', () ->
  invoke 'build:toc'
  invoke 'build:ingredients'

task 'build:toc', 'build a table of contents', () ->
  # pattern matching for files which shouldn't be indexed.
  ignore = (file) -> file.match /^\.|readme|index|table_of_contents|node_modules|writing/i

  # Extract recipe info from a markdown file assuming:
  #   1. a recipe's title is the (non-whitespace) first line
  #   2. a recipe can optionally contain a line of tags which starts
  #      with "tags: " and is followed by a comma separated list of tag phrases.
  recipe_info = (path) ->
    text  = (FS.readFileSync path, { encoding: 'utf8' })
    lines = text.split("\n")
    lines.shift() while lines[0].match(/^\s*$/)

    name = lines[0].match(/^(\s*#+\s*)?([^\n]+)$/)[2]
    tags = text.match(/tags\s*:\s*([^\n]+)/i)?[1].split(',') || []
    { name: name, path: path, tags: tags }

  section_info = (path) ->
    name = capitalize(spacify(Path.basename(path)))
    { name: name, path: path, contents: index_dir(path) }

  index_dir = (base, index = {}) ->
    files = FS.readdirSync(base)
    index.markdown = (recipe_info(Path.join(base, file)) for file in files when Path.extname(file).match(/md|markdown|mdown$/) and not ignore(file))
    index.sections = (section_info(file) for file in files when FS.lstatSync(Path.join(base, file)).isDirectory() and not ignore(file))
    return index

  topic_sort = (sections) ->
    sorted_sections = []
    sort_order = ['full_tacos',
                   'base_layers',
                   'mixins',
                   'condiments',
                   'seasonings',
                   'shells',
                   'like_tacos']

    # find the sections listed in the sorting index
    # and place them in the correct positions in the
    # sorted sections.
    for section_path, sort_position in sort_order
      do (section_path) ->
        section_position = (section.path for section in sections).indexOf(section_path)
        sorted_sections[sort_position] = sections[section_position] if section_position > -1

    # add everything that isn't in the sorted order to the end of the sorted_sections
    sorted_sections.concat(section for section in sections when sort_order.indexOf(section.path) == -1)
    return sorted_sections

  template_sections = (index, base, tabs = "") ->
    #console.log("INDEX", index)
    recipe_link = (recipe) ->
      quick_tags = ""
      quick_tags += " (v)" if recipe.tags.indexOf('vegetarian') >= 0
      "[#{recipe.name}#{ quick_tags }](#{recipe.path})"

    section_link = (section) ->
      subsections = template_sections(section.contents, section.path, tabs + "\t")
      "[#{section.name}](#{section.path}/#readme)\n#{ subsections }"

    markup = ""
    markup += "#{ tabs }* #{ section_link(section) }" for section in topic_sort(index.sections)
    markup += "#{ tabs }* #{ recipe_link(recipe) }\n" for recipe in index.markdown
    markup

  console.log("generating Index.md...")
  FS.writeFile 'INDEX.md', """
Full Index
=================

Welcome to the tacofancy table of contents.  This table of contents was automatically created by scanning through the tacofancy repository for recipes.  Apologies to the newly unemployed index updaters.

Recipes marked with a (v) are tagged as vegetarian friendly. If you'd like to tag more recipes, just look for (or add) a line at the end of each recipe that starts with "tags:". Specifically to mark a recipe with a (v), the tacobot is looking for "tags: vegetarian" or "tags: vegan" or both, separated by a comma.

#{template_sections(index_dir('.'))}
"""


task 'build:ingredients', 'build an ingredient index.', () ->
  # Find all markdown files in the repository.
  glob '**/*.md', {}, (error, files) ->
    is_ingredient = (line) ->
      line.match /^(\*|-)\s+/i

    parse_ingredient = (line) ->
      ingredient = line.match(/^((\*|-)\s+)([^\n]+)$/)[3]
      console.log ingredient
      ingredient

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
    ingredients = make_index(extract_ingredients_from(file) for file in files when not file.match /(readme|index|table_of_contents).md$/i)
    FS.writeFile 'IngredientIndex.md', template_index(ingredients)
    console.log('completed')

"""
Random notes:

`ack --output='$1' "\(v[^(]+\(\/?([^)]+)" INDEX.md | xargs mate` will open the list of files currently
listed in the index as vegetarian assuming that you're on a *nix system, have "ack" installed, and use textmate.
"""
