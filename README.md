# Intro

My goal was to make it readable and simple so it is not perfect and can be improved or encapsulated. For instance, I didn't use Sequel models, used limited features from dry-rb and RSpec.

# Setup

- `bundle install` - installs gems
- Edit db config in `app/main.rb`
- `rake db_create` - creates and populates db

# Development

- `bundle exec guard` - runs tests on update and install gems
- `rerun rackup` - runs api and restarts on changes
- `rspec` or `rake` - runs RSpec tests too

# Production

- deployed to [https://movstox-api-test.herokuapp.com/](https://movstox-api-test.herokuapp.com/)
- swagger docs browseable at [https://movstox-api-test.herokuapp.com/api/v1/swagger_doc](https://movstox-api-test.herokuapp.com/api/v1/swagger_doc) via swagger ui:

1. [https://petstore.swagger.io/](https://petstore.swagger.io/)
2. or you can run it locally on port 8080 via docker `docker run --rm -p 8080:8080 swaggerapi/swagger-ui`

- api url is [https://movstox-api-test.herokuapp.com/api/v1](https://movstox-api-test.herokuapp.com/api/v1)

# Info on API requests

\*`GET /api/v1/movies?day_of_week=Fri`
returns array of `Movie` models

\*`POST /api/v1/movies`
returns hash for `Movie` model

\*`GET /api/v1/bookings?on_date=2019-10-21`
returns array of `Booking` models

\*`GET /api/v1/bookings?date_range[from]=2019-10-21&date_range[to]=2019-10-23`
returns array of `Booking` models

\*`POST /api/v1/bookings`
returns hash for `Booking` model

# Info on models

## Movie

- `id` - primary key
- `name`, `description`, `image_cover_url` - movie info
- `screening_days` - Mon to Sun, comma separated if multiple

## Booking

- `id` - primary key
- `movie_id` - reference to Movie
- `on_date` - booking date
- `seats_occupied` - # of people booked this movie/date
