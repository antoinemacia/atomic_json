# frozen_string_literal: true

require 'atomic_json/json_query_helpers'

module AtomicJson
  class Query

    class Error < StandardError; end
    class TypeError < Error; end

    include AtomicJson::JsonQueryHelpers

    attr_reader :record, :connection
    attr_accessor :query_string

    delegate :quote_column_name, :quote_table_name, :quote, to: :connection

    def initialize(record)
      @connection = ActiveRecord::Base.connection
      @record = record
    end

    def build(hash, touch: false)
      self.query_string = <<~SQL
        UPDATE #{quote_table_name(record.class.table_name)}
        SET #{build_set_subquery(hash, touch)}
        WHERE id = #{quote(record.id)};
      SQL
      self
    end

    def execute!
      connection.exec_update(query_string)
    rescue ActiveRecord::StatementInvalid => e
      raise Error, e.message
    end

    def to_s
      query_string
    end

    private

      def build_set_subquery(hash, touch)
        updates = json_updates_agg(hash)
        updates << timestamp_update if touch
        updates.join(',')
      end

      def json_updates_agg(hash)
        hash.map do |column, payload|
          validate_input!(column, payload)
          "#{quote_column_name(column)} = #{json_deep_merge(column, payload)}"
        end
      end

      def timestamp_update
        "#{quote_column_name(:updated_at)} = #{Time.now}"
      end

      def json_deep_merge(target, payload)
        loop do
          keys, value = traverse_payload(Hash[*payload.shift])
          target = jsonb_set_query_string(target, keys, value)
          break target if payload.empty?
        end
      end

      ##
      # Traverse the Hash payload, incrementally
      # aggregating all hash keys into an array
      # and use the last child as value
      def traverse_payload(attributes, keys = [])
        loop do
          key, val = attributes.flatten
          keys << key.to_s
          break [keys, val] unless val.is_a?(Hash) && val.keys.count == 1
          attributes = val
        end
      end

      def jsonb_set_query_string(target, keys, value)
        <<~EOF
          jsonb_set(
            #{target}::jsonb,
            #{jsonb_quote_keys(keys)},
            #{multiple_values?(value) ? concatenation(target, keys, value) : jsonb_quote_value(value)}
          )::jsonb
        EOF
      end

      def validate_input!(column, payload)
        raise TypeError unless json_column_type?(record, column) && valid_payload_type?(payload)
      end
  end
end
