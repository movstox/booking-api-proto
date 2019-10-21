# frozen_string_literal: true

require_relative 'services/booking_service'

module V1
  class Bookings < Grape::API
    format :json

    namespace :bookings do
      desc 'Get bookings'
      params do
        optional :on_date, type: Date
        optional :date_range, type: Hash do
          requires :from, type: Date
          requires :to, type: Date
        end
        mutually_exclusive :on_date, :date_range
      end
      get '/' do
        FindBooking.new.call(params) do |m|
          m.success { |bookings| bookings }
          m.failure { |error| error! error, 422 }
        end
      end

      desc 'Create a booking'
      params do
        requires :movie_id, type: Integer
        requires :on_date, type: Date
      end
      post '/' do
        CreateBooking.new.call(params) do |m|
          m.success { |booking| booking }
          m.failure { |error| error! error, 422 }
        end
      end
    end
  end
end
