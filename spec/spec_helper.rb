# frozen_string_literal: true

require "active_record"
require "searchkick"
require "faraday"
require "elasticsearch"
require "rrf"
require "rspec"

# Mock ActiveRecord and Searchkick models
class MockRecord < ActiveRecord::Base
  self.abstract_class = true
  include RRF::Model
end

RSpec.configure do |config|
  # Enable :focus tag and run focused tests
  config.filter_run_when_matching :focus

  config.before(:suite) do
    ActiveRecord::Base.establish_connection(
      adapter: "sqlite3",
      database: ":memory:"
    )

    ActiveRecord::Schema.define do
      create_table :chunks, force: true do |t|
        t.string :body
        t.timestamps
      end
    end

    class Chunk < MockRecord
    end
  end

  config.before(:each) do
    Chunk.delete_all
  end
end