# frozen_string_literal: true

require 'spec_helper'

describe AwesomeApi::V1::Movies, type: :api do
  shared_context 'movie info' do
    let(:api_schema) do
      Dry::Schema.JSON do
        required(:name).filled(:string)
        required(:description).maybe(:string)
        required(:cover_image_url).maybe(:string)
        required(:screening_days).maybe(:string)
      end
    end
    let(:movie_params) { db_movie_params }
  end

  describe 'POST /movies' do
    include_context 'calls api'
    include_context 'movie info'

    context 'with invalid screening days' do
      let(:api_params) { movie_params.merge(screening_days: 'hehe') }
      it 'returns 422' do
        expect(api_response.status).to eq(422)
      end
      it 'returns an error' do
        expect(api_response_as_json.keys).to include 'error'
      end
      it 'produces correct error message' do
        expect(api_response_as_json['error']).to eq 'Screening days should be within Mon,Tue,Wed,Thu,Fri'
      end
    end

    context 'with valid inputs' do
      let(:api_params) { movie_params }

      it 'returns 201' do
        expect(api_response.status).to eq(201)
      end

      it 'returns no errors' do
        expect(api_response_as_json['error']).to be_nil
      end

      it 'is dry-schema' do
        validation_result = api_schema.call(api_response_as_json)
        expect(validation_result.success?).to be_truthy
      end
    end
  end

  describe 'GET /movies' do
    include_context 'calls api'

    context 'with unsupported day_of_week' do
      let(:api_params) { { day_of_week: 'hehe' } }
      it 'returns 422' do
        expect(api_response.status).to eq(422)
      end
      it 'requires day_of_week param' do
        expect(api_response_as_json).to be_a_kind_of Hash
        expect(api_response_as_json).to include 'error'
        expect(api_response_as_json['error']).to include('Provide valid week day abbr')
      end
    end
    context 'without day_of_week info' do
      it 'returns 400' do
        expect(api_response.status).to eq(400)
      end

      it 'requires day_of_week param' do
        expect(api_response_as_json).to be_a_kind_of Hash
        expect(api_response_as_json).to include 'error'
        expect(api_response_as_json['error']).to include('day_of_week is missing')
      end
    end
  end

  describe 'GET /movies?day_of_week=Mon' do
    include_context 'calls api'
    include_context 'movie info'

    let(:movies) { db_connection.from(:movies) }

    before do
      @movie_id = movies.insert(movie_params)
    end

    after do
      movies.where { id == @movie_id }.delete
    end

    context 'without movies' do
      let(:api_params) { { day_of_week: week_day_abbr_for(Date.tomorrow) } }

      it 'returns nothing' do
        puts api_response_as_json
        expect(api_response_as_json).to be_empty
      end
    end

    context 'with movies' do
      let(:api_params) { { day_of_week: 'Mon' } }

      it 'returns 200' do
        expect(api_response.status).to eq(200)
      end

      it 'returns a list of movies' do
        expect(api_response_as_json).to be_a_kind_of Array
      end

      it 'is dry-schema' do
        validation_result = api_schema.call(api_response_as_json.first)
        expect(validation_result.success?).to be_truthy
      end
    end
  end
end
