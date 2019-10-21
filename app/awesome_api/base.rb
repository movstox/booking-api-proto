# frozen_string_literal: true

require 'grape'
require_relative 'v1/base'

class AwesomeApi < Grape::API
  format :json
  prefix :api

  mount V1::Base
end
