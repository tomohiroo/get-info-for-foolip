# encoding: utf-8

require "romaji/core_ext/string"

class V1::StationsController < ApplicationController
  def index
    query = station_params[:station_query]
    roman_query = Zipang.to_slug(query.tr('０-９ａ-ｚＡ-Ｚ　', '0-9a-zA-Z ').romaji).gsub(/\-/, '')
    stations = Station.where(['name LIKE ? OR roman LIKE ?', "#{query}", "#{roman_query}"])
    if stations.length < 10
      stations += Station.where(['name LIKE ? OR roman LIKE ?', "#{query}%", "#{roman_query}%"])
      stations.uniq!
      if stations.length < 10
        stations += Station.where(['name LIKE ? OR roman LIKE ?', "%#{query}%", "%#{roman_query}%"])
        stations.uniq!
      end
    end
    render json: stations.first(10)
  end

  private

    def station_params
      params.permit(:station_query)
    end

end
