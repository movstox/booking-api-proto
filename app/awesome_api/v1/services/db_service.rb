# frozen_string_literal: true

require 'sequel'

module V1
  module DbService
    def app_db_props
      App.config.database.to_h
    end

    def conn(custom_db_props = {})
      @conn ||= Sequel.connect(app_db_props.merge(custom_db_props))
    end

    def table_for(entity_sym)
      conn.from(entity_sym)
    end
  end
end
