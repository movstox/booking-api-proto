# frozen_string_literal: true

require 'spec_helper'

describe AwesomeApi::V1::Bookings, type: :api do
  shared_context 'with booking info' do
    let(:api_schema) do
      Dry::Schema.JSON do
        required(:on_date).filled(:date)
        required(:movie_id).filled(:integer)
        required(:seats_occupied).filled(:integer)
      end
    end
    let(:booking_params) { db_booking_params(movie_id: @movie_id) }
    let(:movie_params) { db_movie_params }

    before do
      @movie_id = db_connection.from(:movies).insert(movie_params)
    end

    after do
      db_connection.from(:movies).where { id == @movie_id }.delete
    end
  end

  shared_context 'with one booking created' do
    let(:bookings) { db_connection.from(:bookings) }

    before do
      @booking_id = bookings.insert(booking_params)
    end

    after do
      bookings.where { id == @booking_id }.delete
    end
  end

  shared_context 'a booking created with all seats occupied' do
    let(:bookings) { db_connection.from(:bookings) }

    before do
      @booking_id2 = bookings.insert(booking_params.merge(seats_occupied: V1::MAX_SEATS_PER_MOVIE))
    end

    after do
      bookings.where { id == @booking_id2 }.delete
    end
  end

  describe 'GET /bookings' do
    include_context 'calls api'
    let(:api_params) { {} }

    context 'without range provided' do
      it_behaves_like 'endpoint returning error message', 422, 'date range is not specified: use on_date or date_range param'
    end
  end

  describe 'POST /bookings' do
    include_context 'calls api'
    include_context 'with booking info'

    let(:api_params) { booking_params }

    context 'when movie is not screened' do
      let(:api_params) { booking_params.merge(on_date: Date.tomorrow) }
      it_behaves_like 'endpoint returning error message', 422, 'Movie is not screened on this date'
    end

    context 'for non-existing movies' do
      let(:api_params) { booking_params.merge(movie_id: -1) }
      it_behaves_like 'endpoint returning error message', 422, 'Movie is not found'
    end

    context 'booking date is in the past' do
      include_context 'with one booking created'
      let(:api_params) { booking_params.merge(on_date: Date.today - 1.day) }
      it_behaves_like 'endpoint returning error message', 422, 'Booking date cannot be in the past'
    end

    context 'does not allow overbooking' do
      include_context 'a booking created with all seats occupied'
      it_behaves_like 'endpoint returning error message', 422, 'Movie for this date is fully booked'
    end

    context 'creates new booking ' do
      it_behaves_like 'endpoint responding with', 201, Hash
      it 'returns no errors' do
        expect(api_response_as_json['error']).to be_nil
      end

      it 'is dry-schema' do
        validation_result = api_schema.call(api_response_as_json)
        expect(validation_result.success?).to be_truthy
      end

      it 'increments number of bookings for given date and movie' do
        expect(api_response_as_json['seats_occupied']).to eq(1)
      end
    end
  end

  describe format('GET /bookings?date_range[from]=%s&date_range[to]=%s', Date.today, Date.tomorrow) do
    include_context 'calls api'
    include_context 'with booking info'
    include_context 'with one booking created'

    context 'given valid date range' do
      let(:api_params) { { date_range: { from: Date.yesterday, to: Date.tomorrow } } }

      it 'returns bookings' do
        expect(api_response_as_json).to be_a_kind_of Array
      end

      it 'is dry-schema' do
        validation_result = api_schema.call(api_response_as_json.first)
        expect(validation_result.success?).to be_truthy
      end
    end

    context 'given empty date range' do
      let(:api_params) { { date_range: { from: (Date.today - 1.year), to: Date.today - 1.month } } }

      it 'returns no bookings' do
        expect(api_response_as_json).to be_empty
      end
    end
  end

  describe 'GET /bookings?on_date=%s' % Date.today do
    include_context 'calls api'
    include_context 'with booking info'
    include_context 'with one booking created'

    let(:api_params) { { on_date: Date.today } }

    it_behaves_like 'endpoint responding with', 200, Array
    it 'is dry-schema' do
      validation_result = api_schema.call(api_response_as_json.first)
      expect(validation_result.success?).to be_truthy
    end
  end
end
