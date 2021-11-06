module Filterable
  extend ActiveSupport::Concern

  def build_filter(hash)
    non_empty = hash.reject { |key, value| value.nil? }
    return "" if non_empty.empty?

    "where #{concat_clauses(non_empty)}"
  end

  private

  def concat_clauses(hash)
    hash.map { |key, value| "#{key} = #{render_value(value)}" }.join(" and ")
  end

  def render_value(value)
    if value.is_a?(Numeric) || value.chars&.first == "$"
      value
    else
      "'#{value}'"
    end
  end
end
