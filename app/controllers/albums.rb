# frozen_string_literal: true

require 'roda'
require_relative './app'

module DFans
  # Web controller for DFans API
  class Api < Roda
    route('albums') do |routing|
      @album_route = "#{@api_root}/albums"

      routing.on String do |album_id|
        routing.on 'photos' do
          @pho_route = "#{@api_root}/albums/#{album_id}/photos"

          # GET api/v1/albums/[album_id]/photos/[photo_id]
          routing.get String do |photo_id|
            pho = Photo.where(album_id: album_id, id: photo_id).first
            pho ? pho.to_json : raise('Photo not found')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end

          # GET api/v1/albums/[album_id]/photos
          routing.get do
            output = { data: Album.first(id: album_id).photos }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, message: 'Could not find photos'
          end

          # POST api/v1/albums/[album_id]/photos
          routing.post do
            new_data = JSON.parse(routing.body.read)
            # Reuse the service Object as in the handout "10-User Account" P.17.
            new_pho = CreatePhotoForAlbum.call(
              album_id: album_id, photo_data: new_data
            )
            response.status = 201
            response['Location'] = "#{@pho_route}/#{new_pho.id}"
            { message: 'Photo saved', data: new_pho }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            Api.logger.error "Unknown error saving photos: #{e.message}"
            routing.halt 500, { message: 'Error creating photos' }.to_json
          end
        end

        # GET api/v1/albums/[album_id]
        routing.get do
          album = Album.first(id: album_id)
          album ? album.to_json : raise('Album not found')
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end

      # GET api/v1/albums
      routing.get do
        account = Account.first(username: @auth_account['username'])
        albums = account.albums
        JSON.pretty_generate(data: albums)
      rescue StandardError
        routing.halt 403, { message: 'Could not find any album' }.to_json
      end

      # POST api/v1/albums
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_album = Album.new(new_data)
        raise('Could not save album') unless new_album.save
        response.status = 201
        response['Location'] = "#{@album_route}/#{new_album.id}"
        { message: 'Album saved', data: new_album }.to_json
      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
        routing.halt 400, { message: 'Illegal Attributes' }.to_json
      rescue StandardError => e
        Api.logger.error "UNKOWN ERROR: #{e.message}"
        routing.halt 500, { message: 'Unknown server error' }.to_json
      end
    end
  end
end
