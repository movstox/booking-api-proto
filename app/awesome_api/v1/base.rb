# frozen_string_literal: true

require 'grape-swagger'
require_relative 'movies'
require_relative 'bookings'

module V1
  class Base < Grape::API
    format :json
    content_type :json, 'application/vnd.api+json'

    namespace :v1 do
      mount V1::Movies
      mount V1::Bookings
    end

    # http://localhost:9292/api/v1/swagger_doc
    add_swagger_documentation(
      hide_documentation_path: true,
      mount_path: 'v1/swagger_doc',
      hide_format: true,
      base_path: '/api'
    )
  end
end
