# frozen_string_literal: true

require 'rack/test' 
include Rack::Test::Methods

require_relative '../require_app' 
require_app

def app 
  DFans::Api
end
