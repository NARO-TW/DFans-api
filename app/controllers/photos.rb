# frozen_string_literal: true

require_relative './app'

module DFans
  # Web controller for Credence API
  class Api < Roda
    route('photos') do |routing|
      unless @auth_account
        routing.halt 403, { message: 'Not authorized' }.to_json
      end

      @pho_route = "#{@api_root}/photos"

      # GET api/v1/photos/[pho_id]
      routing.on String do |pho_id|
        @req_photo = Photo.first(id: pho_id)

        routing.get do
          photo = GetPhotoQuery.call(
            auth: @auth, photo: @req_photo
          )

          { data: photo }.to_json
        rescue GetPhotoQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetPhotoQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          Api.logger.warn "Photo Error: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
