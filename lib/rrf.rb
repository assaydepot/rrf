# frozen_string_literal: true

require_relative "rrf/version"
require "configuration"

module RRF
  class Error < StandardError; end

  # Default configuration
  @configuration = Configuration.new

  class << self
    attr_accessor :configuration

    def configure
      yield(configuration)
    end
  end

  module Model
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def fuse(*result_sets, limit: 10)
        rank_bias = RRF.configuration.rank_bias
        record_scores = Hash.new { |hash, key| hash[key] = { score: 0, id: key, sources: [] } }
  
        result_sets.each do |result_set|
          if result_set.is_a?(ActiveRecord::Relation)
            result_set.select(:id).each_with_index do |record, index|
              score = 1.0 / (rank_bias + index)
              record_scores[record.id][:score] += score
              record_scores[record.id][:sources] << :active_record
            end
          elsif result_set.is_a?(Searchkick::Relation)
            result_set.hits.each_with_index do |hit, index|
              id = hit["_id"]
              score = 1.0 / (rank_bias + index)
              record_scores[id][:score] += score
              record_scores[id][:sources] << :searchkick
            end
          else
            raise RRF::Error, "Unsupported result set type: #{result_set.class}"
          end
        end

        # Sort by score and limit results
        top_record_ids = record_scores.sort_by { |_id, result| -result[:score] }.to_h.keys.first(limit)
  
        # Load actual records from ActiveRecord
        self.where(id: top_record_ids).index_by(&:id).values_at(*top_record_ids).each do |record|
          record.define_singleton_method(:_rrf_score) { record_scores[record.id][:score] }
        end
      end
    end
  end
end