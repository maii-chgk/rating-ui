class MaterializedViews
  ViewDefinition = Struct.new('ViewDefinition', :name, :query, keyword_init: true)

  def self.recreate_all(model:)
    MaterializedViews.new(model).recreate_all
  end

  def initialize(model)
    @model = model
  end

  def recreate_all
    definitions.each { |definition| create_or_refresh_view(definition) }
  end

  private

  def definitions
    [player_ranking, team_ranking]
  end

  def create_or_refresh_view(definition)
    create_query = <<~SQL
      create materialized view if not exists #{@model}.#{definition.name} 
      as #{definition.query}
      with no data
    SQL
    refresh_query = "refresh materialized view #{@model}.#{definition.name}"

    ActiveRecord::Base.connection.exec_query(create_query)
    ActiveRecord::Base.connection.exec_query(refresh_query)
  end

  def player_ranking
    ViewDefinition.new(
      name: "player_ranking",
      query: <<~SQL
        select rank() over (partition by release_id order by rating desc) as place, 
            player_id, rating, rating_change, release_id
        from #{@model}.player_rating
    SQL
  )
  end

  def team_ranking
    ViewDefinition.new(
      name: "team_ranking",
      query: <<~SQL
        select rank() over (partition by release_id order by rating desc) as place,
            team_id, rating, rating_change, release_id
        from #{@model}.team_rating
    SQL
    )
  end
end
