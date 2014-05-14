
class Ingreedy
  parse: (input)->
    pattern = "({{fraction1}})?\\s?
      ({{amount}})?\\s?
      ({{fraction2}})?\\s?
      (\\(({{container_size}})?\\))?\\s?
      ({{unit_and_ingredient}})"
    regex = XRegExp.build(pattern, {
      amount: /.?\d+(\.\d+)?/,
      fraction1: /\d\/\d/,
      fraction2: /\d\/\d/,
      container_size: /\d+(\.\d+)?\s.+/,
      unit_and_ingredient: /.+/
    }, 'x');
    result = XRegExp.exec input, regex
    if result?
      @container_size = result.container_size
      @ingredient_string = result.unit_and_ingredient
      @parse_amount(result.amount, result.fraction1, result.fraction2)
      @parse_unit_and_ingredient()

  parse_amount: (amount_string, fraction1, fraction2)->
    if fraction1?
      numbers = fraction1.split("\/")
      numerator = parseFloat numbers[0]
      denominator = parseFloat numbers[1]
      fraction = numerator / denominator
      @amount = fraction
    else if fraction2?
      numbers = fraction2.split("\/")
      numerator = parseFloat numbers[0]
      denominator = parseFloat numbers[1]
      fraction = numerator / denominator
      @amount = parseFloat(amount_string) + fraction
    else
      @amount = parseFloat(amount_string)

    if @container_size?
      @container_amount = @container_size.match(/\d+(\.\d+)?/)[0]
      @container_unit = @container_size.replace(@container_amount, "").trimLeft()
      @amount *= parseFloat(@container_amount)

  set_unit_variations: (unit, variations)->
    @unit_map ||= {}
    @unit_map[abbrev] = unit for abbrev in variations

  create_unit_map: ->
    # english units
    @set_unit_variations 'cup', ["c.", "c", "cup", "cups"]
    @set_unit_variations 'fluid_ounce', ["fl. oz.", "fl oz", "fluid ounce", "fluid ounces"]
    @set_unit_variations 'gallon', ["gal", "gal.", "gallon", "gallons"]
    @set_unit_variations 'ounce', ["oz", "oz.", "ounce", "ounces"]
    @set_unit_variations 'pint', ["pt", "pt.", "pint", "pints"]
    @set_unit_variations 'pound', ["lb", "lb.", "pound", "pounds"]
    @set_unit_variations 'quart', ["qt", "qt.", "qts", "qts.", "quart", "quarts"]
    @set_unit_variations 'tablespoon', ["tbsp.", "tbsp", "T", "T.", "tablespoon", "tablespoons"]
    @set_unit_variations 'teaspoon', ["tsp.", "tsp", "t", "t.", "teaspoon", "teaspoons"]
    # metric units
    @set_unit_variations 'gram', ["g", "g.", "gr", "gr.", "gram", "grams"]
    @set_unit_variations 'kilogram', ["kg", "kg.", "kilogram", "kilograms"]
    @set_unit_variations 'liter', ["l", "l.", "liter", "liters"]
    @set_unit_variations 'milligram', ["mg", "mg.", "milligram", "milligrams"]
    @set_unit_variations 'milliliter', ["ml", "ml.", "milliliter", "milliliters"]

  parse_unit: ->
    @create_unit_map() unless @unit_map?

    for abbrev, unit of @unit_map
      if @ingredient_string.substring(0, abbrev.length + 1) is "#{abbrev} "
        # if a unit is found, remove it from the ingredient string
        @ingredient_string = @ingredient_string.replace abbrev, ""
        @unit = unit

    # if no unit yet, try it again downcased
    unless @unit?
      @ingredient_string = @ingredient_string.toLowerCase()
      for abbrev, unit of @unit_map
        if @ingredient_string.substring(0, abbrev.length) is "#{abbrev} "
          # if a unit is found, remove it from the ingredient string
          @ingredient_string = @ingredient_string.replace abbrev, ""
          @unit = unit

    # if we still don't have a unit, check to see if we have a container unit
    if @container_unit? and not @unit?
      for abbrev, unit of @unit_map
        @unit = unit if abbrev == @container_unit

  parse_unit_and_ingredient: ->
    @parse_unit()
    # clean up ingredient string
    @ingredient = @ingredient_string.trim()

window.Ingreedy = Ingreedy


