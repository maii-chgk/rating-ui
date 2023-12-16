# frozen_string_literal: true

class ModelIndexer
  def self.run
    model_schemas = schemas.reject { |s| s.start_with?("pg") || %w[public information_schema].include?(s) }
    models = model_schemas.map do |schema|
      {
        name: schema,
        changes_teams: has_teams_table?(schema),
        changes_rosters: has_rosters_table?(schema)
      }
    end

    Model.upsert_all(models, unique_by: :name)
  end

  def self.schemas
    sql = <<~SQL
      select schema_name
      from information_schema.schemata;
    SQL
    ActiveRecord::Base.connection.exec_query(sql).rows.flatten
  end

  def self.has_teams_table?(schema)
    sql = <<~SQL
      select to_regclass('#{schema}.teams');
    SQL
    ActiveRecord::Base.connection.exec_query(sql).rows.first.first.present?
  end

  def self.has_rosters_table?(schema)
    sql = <<~SQL
      select to_regclass('#{schema}.rosters');
    SQL
    ActiveRecord::Base.connection.exec_query(sql).rows.first.first.present?
  end
end
