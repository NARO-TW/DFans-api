# frozen_string_literal: true

require 'roda'
require_relative './app'

module DFans
  # Web controller for DFans API
  class Api < Roda
    route('accounts') do |routing|
      @account_route = "#{@api_root}/accounts"

      routing.on String do |username|
        routing.halt(403, UNAUTH_MSG) unless @auth_account

        # GET api/v1/accounts/[username]
        routing.get do
          auth = AuthorizeAccount.call(
            auth: @auth, username:,
            auth_scope: AuthScope.new(AuthScope::READ_ONLY)
          )
          { data: auth }.to_json
        rescue AuthorizeAccount::ForbiddenError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "GET ACCOUNT ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API Server Error' }.to_json
        end
      end

      # POST api/v1/accounts
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_account = Account.new(new_data)
        raise('Could not save account') unless new_account.save

        response.status = 201
        response['Location'] = "#{@account_route}/#{new_account.username}"
        { message: 'Account created', data: new_account }.to_json
      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "MASS-ASSIGNMENT:: #{new_data.keys}"
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError => e
        Api.logger.error 'Unknown error saving account'
        routing.halt 500, { message: e.message }.to_json
      end
    end
  end
end
