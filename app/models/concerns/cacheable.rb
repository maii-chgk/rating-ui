module Cacheable
  extend ActiveSupport::Concern

  def exec_query_for_single_value(query:, params: nil, cache_key: nil, default_value: nil)
    exec_query_with_cache(query, params, cache_key).rows.first.first
  rescue NoMethodError
    default_value
  end

  def exec_query_for_single_row(query:, params: nil, cache_key: nil)
    exec_query_with_cache(query, params, cache_key).rows.first
  end

  def exec_query_for_hash_array(query:, params: nil, cache_key: nil)
    exec_query_with_cache(query, params, cache_key).to_a
  end

  def exec_query_for_hash(query:, params: nil, cache_key: nil, group_by:)
    exec_query_with_cache(query, params, cache_key)
      .to_a
      .each_with_object(Hash.new { |h, k| h[k] = [] }) do |row, hash|
        hash[row[group_by]] << row
      end
  end

  def exec_query(query:, params: nil, cache_key: nil, result_class:)
    exec_query_with_cache(query, params, cache_key)
      .to_a
      .map { |row| result_class.new(row) }
  end

  private

  def exec_query_with_cache(query, params, cache_key)
    Rails.cache.fetch(cache_key, expires_in: 24.hours) do
      run_query(query, params)
    end
  end

  def run_query(query, params)
    if params.present?
      ActiveRecord::Base.connection.exec_query(query, "", active_record_params(params))
    else
      ActiveRecord::Base.connection.exec_query(query)
    end
  end

  def active_record_params(params)
    params.map { |param| [nil, param] }
  end
end
