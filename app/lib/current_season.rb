# frozen_string_literal: true

module CurrentSeason
  def self.title
    fetch_current_season! unless @current_season_title
    @current_season_title
  end

  def self.id
    fetch_current_season! unless @current_season_id
    @current_season_id
  end

  def self.fetch_current_season!
    sql = <<~SQL
      select id, to_char("start", 'YYYY') || '/' || to_char("end", 'YY') as season
      from public.seasons
      where current_date between "start" and "end"
    SQL

    @current_season_id, @current_season_title = ActiveRecord::Base.connection.exec_query(sql).rows.first
  end
end
