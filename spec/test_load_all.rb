# frozen_string_literal: true

# require 'rack/test' 
# include Rack::Test::Methods

require_relative '../require_app'
require_app

def app
  DFans::Api
end

def app = DFans::Api
unless app.environment == :production
  require 'rack/test' 
  include Rack::Test::Methods  # rubocop:disable Style/MixinUsage
end
