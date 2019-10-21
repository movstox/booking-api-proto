# frozen_string_literal: true

require_relative 'services/movie_service'

module V1
  class Movies < Grape::API
    format :json

    namespace :movies do
      desc 'Get movies'
      params do
        requires :day_of_week, type: String, desc: 'Movie screening day of week'
      end
      get '/' do
        FindMovie.new.call(params) do |m|
          m.success { |movies| movies }
          m.failure { |error| error! error, 422 }
        end
      end

      desc 'Create a movie'
      params do
        requires :name, type: String
        requires :description, type: String
        requires :cover_image_url, type: String
        requires :screening_days, type: String
      end
      post '/' do
        CreateMovie.new.call(params) do |m|
          m.success { |movie| movie }
          m.failure { |error| error! error, 422 }
        end
      end
    end
  end
end
