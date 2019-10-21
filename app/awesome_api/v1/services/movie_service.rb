# frozen_string_literal: true

require_relative 'db_service'
require 'dry/transaction'

module V1
  class CreateMovie
    include DbService
    include Dry::Transaction

    WEEK_DAY_ABBR_REGEX = /^(Mon|Tue|Wed|Thu|Fri)$/i.freeze

    step :validate
    step :create

    private

    def validate(movie_params)
      screening_days_valid = movie_params['screening_days'].split(',').map(&method(:valid_week_day?))

      return Failure('Screening days should be within Mon,Tue,Wed,Thu,Fri') unless screening_days_valid.all?

      Success(movie_params)
    end

    def create(movie_params)
      movie_id = table_for(:movies).insert(movie_params)
      movie = table_for(:movies).where(id: movie_id).first
      return Success(movie) if movie

      Failure(:create)
    end

    def valid_week_day?(day_abbr)
      day_abbr =~ WEEK_DAY_ABBR_REGEX
    end
  end

  class FindMovie
    include DbService
    include Dry::Transaction

    step :validate
    step :lookup_by_week_day

    private

    def validate(input)
      extract_day_abbr(input)
    end

    def extract_day_abbr(input)
      day_abbr = input['day_of_week']
      valid_input = %w[Mon Tue Wed Thu Fri Sat].include?(day_abbr)
      return Failure('Provide valid week day abbr') unless valid_input

      Success(day_abbr)
    end

    def lookup_by_week_day(day_abbr)
      cond = Sequel.like(:screening_days, Regexp.new(day_abbr, 'i'))
      movies = table_for(:movies).where(cond).to_a

      Success(movies)
    end
  end
end
