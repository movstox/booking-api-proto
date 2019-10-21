# frozen_string_literal: true

require_relative '../app/main'

class App
  extend Dry::Configurable

  setting :database do
    setting(:adapter, 'postgres', &:to_sym)
    setting :host, 'localhost'
    setting :port, 5432
    setting :database, 'awesome_api_test'
    setting :user, 'postgres'
    setting :password, ''
    setting :max_connections, 10
  end
end
