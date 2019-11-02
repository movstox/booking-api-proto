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
      it_behaves_like 'endpoint returning error message', 422, 'Screening days should be within Sun,Mon,Tue,Wed,Thu,Fri,Sat'
    end

    context 'with valid inputs' do
      let(:api_params) { movie_params }

      it_behaves_like 'endpoint responding with', 201, Hash

      it 'returns no errors' do
        expect(api_response_as_json.dig('error')).to be_nil
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
      it_behaves_like 'endpoint returning error message', 422, 'Provide valid week day abbr'
    end
    context 'without day_of_week info' do
      it_behaves_like 'endpoint returning error message', 400, 'day_of_week is missing'
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

      it_behaves_like 'endpoint responding with', 200, Array
      it 'returns nothing' do
        expect(api_response_as_json).to be_empty
      end
    end

    context 'with movies' do
      let(:api_params) { { day_of_week: 'Mon' } }

      it_behaves_like 'endpoint responding with', 200, Array
      it 'is dry-schema' do
        validation_result = api_schema.call(api_response_as_json.first)
        expect(validation_result.success?).to be_truthy
      end
    end
  end
end
