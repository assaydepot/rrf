# RRF

RRF (Reciprocal Rank Fusion) is a Ruby gem that provides an implementation of the Reciprocal Rank Fusion (RRF) algorithm to merge and rank results from different search engines, specifically supporting ActiveRecord and Searchkick.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rrf'
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install rrf
```

## Usage

To use RRF, include the module in your ActiveRecord model and configure it as needed.

### Example

Let’s assume you have a model named Chunk that uses both ActiveRecord (with pgvector) and Searchkick:

```ruby
class Chunk < ApplicationRecord
  include Searchkick
  include RRF::Model

  # ActiveRecord vector search using pgvector
  # Assuming `embedding768` is a column of type `vector` (pgvector)

  # Define any additional logic or methods as needed
end
```

### Performing Searches and Fusing Results

You can perform searches using ActiveRecord and Searchkick, and then fuse the results using the fuse method (the following relies on the [neighbor gem](https://github.com/ankane/neighbor) and the [red-candle gem](https://github.com/assaydepot/red-candle)):

```ruby
# Configure the constant value if needed
RRF.configure do |config|
  config.rank_bias = 70 # User-defined value
end

# Perform Searchkick search
es_result = Chunk.search("alpaca", load: false, limit: 50)

# Perform ActiveRecord nearest neighbor search
query_embedding = Candle::Model.new.embedding("alpaca")
ar_result = Chunk.all.nearest_neighbors(:embedding768, query_embedding, distance: :cosine).limit(50)

# Fuse the results and limit to 10
result = Chunk.fuse(ar_result, es_result, limit: 10)

# `result` now contains the top 10 fused search results
```

### Configuration

You can configure the rank_bias value used in the RRF algorithm:

```ruby
RRF.configure do |config|
  config.rank_bias = 70 # Default is 60
end
```

## Development

After checking out the repo, run 

```sh
bundle install
```

Then, run 

```sh
rake spec
```
to run the tests.

To install this gem onto your local machine, run 

```sh
bundle exec rake install
```

To release a new version, update the version number in version.rb, and then run

```sh
bundle exec rake release
```

which will create a git tag for the version, push git commits and tags, and push the .gem file to rubygems.org.

To use this locally during development, I like to include it whatever project I'm working by adding the following to the `Gemfile` of the other project

```ruby
gem "rrf", path: '/what/ever/path/you/choose/rrf'
```

Then bundle and it will use your development copy.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/assaydepot/rrf.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
