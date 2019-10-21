# frozen_string_literal: true

require_relative 'app/main'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:run_tests)
task default: %w[run_tests]

task :db_create do
  include V1::DbService

  def create_db_via(db_props)
    pg_props = db_props.merge(database: 'postgres')
    Sequel.connect(pg_props) do |db|
      db.execute 'DROP DATABASE IF EXISTS %s' % db_props[:database]
      db.execute 'CREATE DATABASE %s' % db_props[:database]
    end

    puts '[%s] (Re-)Creating database' % db_props[:database]
    db_conn = Sequel.connect(db_props)

    puts '[%s] Creating "movies" table' % db_props[:database]
    db_conn.create_table! :movies do
      primary_key :id
      String :name
      String :description
      String :cover_image_url
      String :screening_days
    end

    puts '[%s] Creating "bookings" table' % db_props[:database]
    db_conn.create_table! :bookings do
      primary_key :id
      foreign_key :movie_id, :movies
      Date :on_date
      Integer :seats_occupied, default: 0
      index %i[movie_id on_date], unique: true
    end
    puts '[%s] Database created.' % db_props[:database]
  end

  development_props = app_db_props

  test_props = development_props.merge(database: app_db_props[:database] + '_test')

  create_db_via(development_props)
  create_db_via(test_props)
end
