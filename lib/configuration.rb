module RRF
  class Configuration
    attr_accessor :rank_bias

    def initialize
      @rank_bias = 60 # Default value
    end
  end
end