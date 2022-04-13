# frozen_string_literal: true

require './require_app'
require_app

run DFans::Api.freeze.app
