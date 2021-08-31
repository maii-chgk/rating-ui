module Cacheable
  extend ActiveSupport::Concern

  def exec_query_with_cache(query:, params: nil, cache_key: nil)
    Rails.cache.fetch("#{cache_key_with_version}/#{cache_key}", expires_in: 24.hours) do
      if params.present?
        ActiveRecord::Base.connection.exec_query(query, "", [params])
      else
        ActiveRecord::Base.connection.exec_query(query)
      end
    end
  end
end
