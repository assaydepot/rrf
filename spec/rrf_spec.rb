# frozen_string_literal: true

require "spec_helper"

RSpec.describe RRF::Model do
  describe ".fuse" do
    let!(:chunk1) { Chunk.create!(body: "hello world") }
    let!(:chunk2) { Chunk.create!(body: "hi there") }
    let!(:chunk3) { Chunk.create!(body: "hello again") }

    it "fuses results from ActiveRecord and Searchkick" do
      # Mocking Searchkick results
      search_hits = [
        { "_id" => chunk1.id },
        { "_id" => chunk2.id }
      ]
      search_results = instance_double(Searchkick::Relation)
      search_results.define_singleton_method(:hits) { search_hits }
      allow(search_results).to receive(:is_a?).with(ActiveRecord::Relation).and_return(false)
      allow(search_results).to receive(:is_a?).with(Searchkick::Relation).and_return(true)
      allow(Chunk).to receive(:search).and_return(search_results)

      ar_result = Chunk.where("body like ?", "%hello%")
      es_result = Chunk.search("hello", load: false)

      fused_results = Chunk.fuse(ar_result, es_result, limit: 2)

      expect(fused_results.size).to eq(2)
      expect(fused_results).to include(chunk1)
      expect(fused_results).to include(chunk3)
    end

    it "limits the number of results" do
      search_hits = [
        { "_id" => chunk1.id },
        { "_id" => chunk2.id }
      ]
      search_results = instance_double(Searchkick::Relation)
      search_results.define_singleton_method(:hits) { search_hits }
      allow(search_results).to receive(:is_a?).with(ActiveRecord::Relation).and_return(false)
      allow(search_results).to receive(:is_a?).with(Searchkick::Relation).and_return(true)
      allow(Chunk).to receive(:search).and_return(search_results)

      ar_result = Chunk.where("body like ?", "%hello%")
      es_result = Chunk.search("hello", load: false)

      fused_results = Chunk.fuse(ar_result, es_result, limit: 1)
      expect(fused_results.size).to eq(1)
    end

    it "raises an error for unsupported result set types" do
      expect {
        Chunk.fuse(["unsupported"], limit: 1)
      }.to raise_error(RRF::Error, "Unsupported result set type: Array")
    end

    it "correctly calculates and assigns scores" do
      search_hits = [
        { "_id" => chunk1.id },
        { "_id" => chunk2.id }
      ]
      search_results = instance_double(Searchkick::Relation)
      search_results.define_singleton_method(:hits) { search_hits }
      allow(search_results).to receive(:is_a?).with(ActiveRecord::Relation).and_return(false)
      allow(search_results).to receive(:is_a?).with(Searchkick::Relation).and_return(true)
      allow(Chunk).to receive(:search).and_return(search_results)

      ar_result = Chunk.where("body like ?", "%hello%")
      es_result = Chunk.search("hello", load: false)

      fused_results = Chunk.fuse(ar_result, es_result, limit: 2)
      expect(fused_results.first._rrf_score).to be > 0
    end
  end
end
