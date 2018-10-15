# encoding: utf-8

require "romaji/core_ext/string"

class V1::CategoriesController < ApplicationController

  def index
    query = category_params[:category_query]
    roman_query = Zipang.to_slug(query.tr('０-９ａ-ｚＡ-Ｚ　', '0-9a-zA-Z ').romaji).gsub(/\-/, '')
    categories = Category.where(['name LIKE ? OR roman LIKE ?', "#{query}%", "#{roman_query}%"])
    if categories.length < 10
      categories += Category.where(['name LIKE ? OR roman LIKE ?', "%#{query}%", "%#{roman_query}%"])
    end
    render json: categories.uniq.first(10)
  end

  private

    def category_params
      params.permit(:category_query)
    end

end
