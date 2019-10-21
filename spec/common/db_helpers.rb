# frozen_string_literal: true

module DbHelpers
  include ::AwesomeApi::V1::DbService

  def db_booking_params(movie_id:)
    {
      on_date: Date.today.to_s,
      movie_id: movie_id,
      seats_occupied: 0
    }
  end

  def db_movie_params
    {
      name: 'Maleficent: Mistress of Evil',
      description: 'cool movie',
      cover_image_url: 'https://m.media-amazon.com/images/M/MV5BZjJiYTExOTAtNWU0Yi00NzJjLTkwOTgtOTU2NWM1ZjJmYWVhXkEyXkFqcGdeQXVyMTkxNjUyNQ@@._V1_UX182_CR0,0,182,268_AL_.jpg',
      screening_days: week_day_abbr_for(Date.today)
    }
  end

  def week_day_abbr_for(given_date)
    Date::ABBR_DAYNAMES[given_date.wday]
  end

  def db_connection
    conn
  end
end
