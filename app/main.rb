# frozen_string_literal: true

require_relative 'awesome_api/base'

class App
  extend Dry::Configurable

  setting :database do
    setting :adapter, :postgres
    setting :host, 'localhost'
    setting :port, 5432
    setting :database, 'awesome_api_dev'
    setting :user, 'postgres'
    setting :password, ''
    setting :max_connections, 10
  end
end
