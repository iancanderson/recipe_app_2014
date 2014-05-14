# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class Recipes

$ ->
  $('#ingredient_addition_natural').keyup ->
    parser = new Ingreedy
    parser.parse this.value
    $('#ingreedy_amount').val(parser.amount)
    $('#ingreedy_unit').val(parser.unit)
    $('#ingreedy_ingredient').val(parser.ingredient)
    $('#ingreedy_image').html("<img width=200 height=200 src='http://#{parser.ingredient.replace(' ', '')}.jpg.to' />")

