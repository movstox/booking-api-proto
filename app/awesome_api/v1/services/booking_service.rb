# frozen_string_literal: true

require_relative 'db_service'
require 'dry/transaction'

module V1
  MAX_SEATS_PER_MOVIE = 10

  class CreateBooking
    include DbService
    include Dry::Transaction

    step :validate_booking_date
    step :validate_movie_and_screening_day
    step :reserve_seat

    private

    def validate_booking_date(input)
      return Failure('Booking date cannot be in the past') if in_the_past?(input['on_date'])

      Success(input)
    end

    def validate_movie_and_screening_day(input)
      movie = find_movie(input['movie_id'])
      return Failure('Movie is not found') unless movie.present?

      movie_screened = movie[:screening_days].split(',').include?(week_day_abbr_for(input['on_date']))
      return Failure('Movie is not screened on this date') unless movie_screened

      Success(input)
    end

    def booking_for(input)
      booking = find_booking(input)
      booking = create_booking(input) if booking.nil?
      return Failure('Cannot create booking') if booking.nil?

      Success(booking)
    end

    def reserve_seat(input)
      bookings_on_date = find_bookings(input)
      booking_for(input).bind do |booking|
        rows_updated =
          conn.transaction do
            if fully_booked?(booking)
              return Failure('Movie for this date is fully booked')
            end

            seats_currently_occupied = booking.dig(:seats_occupied).to_i
            booking.update(seats_occupied: seats_currently_occupied + 1)
            bookings_on_date.update(seats_occupied: seats_currently_occupied + 1)
          end
        return Failure('Cannot book a seat') if rows_updated != 1

        Success(booking)
      end
    end

    def find_bookings(input)
      table_for(:bookings).where(
        movie_id: input['movie_id'],
        on_date: input['on_date']
      )
    end

    def find_booking(input)
      find_bookings(input).first
    end

    def find_movie(id)
      table_for(:movies).where(id: id)&.first
    end

    def in_the_past?(given_date)
      given_date < Date.today
    end

    def week_day_abbr_for(given_date)
      Date::ABBR_DAYNAMES[given_date.wday]
    end

    def fully_booked?(booking)
      booking[:seats_occupied].to_i == V1::MAX_SEATS_PER_MOVIE
    end

    def create_booking(booking_params)
      booking_id = table_for(:bookings).insert(booking_params)
      new_booking = table_for(:bookings).where(id: booking_id).first
      new_booking
    rescue Sequel::ForeignKeyConstraintViolation
      nil
    end
  end

  class FindBooking
    include DbService
    include Dry::Transaction

    step :validate
    step :lookup

    private

    def validate(lookup_params)
      date_range = extract_date_range(lookup_params)
      valid_range?(date_range)
    end

    def lookup(date_range)
      bookings = table_for(:bookings).where(on_date: date_range).to_a

      Success(bookings)
    end

    def extract_date_range(lookup_params)
      if lookup_params.key?('on_date')
        return (lookup_params['on_date']..lookup_params['on_date'])
      end

      date_range = lookup_params['date_range']
      date_range&.dig('from')..date_range&.dig('to')
    end

    def valid_range?(date_range)
      from = date_range.begin
      to = date_range.end

      range_with_empty_dates = from.nil? || to.nil?
      return Failure('date range is not specified: use on_date or date_range param') if range_with_empty_dates

      return Failure('from date should be after to date') if to < from

      Success(date_range)
    end
  end
end
