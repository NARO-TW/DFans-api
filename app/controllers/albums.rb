# frozen_string_literal: true

require_relative './app'

module DFans
  # Web controller for DFans API
  class Api < Roda
    route('albums') do |routing|
      routing.halt(403, UNAUTH_MSG) unless @auth_account

      @album_route = "#{@api_root}/albums"
      routing.on String do |album_id|
        @req_album = Album.first(id: album_id)

        # GET api/v1/albums/[ID]
        routing.get do
          album = GetAlbumQuery.call(auth: @auth, album: @req_album)
          { data: album }.to_json
        rescue GetAlbumQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetAlbumQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND ALBUM ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        routing.on('photos') do
          # POST api/v1/albums/[album_id]/photos
          routing.post do
            new_photo = CreatePhoto.call(
              auth: @auth,
              album: @req_album,
              photo_data: JSON.parse(routing.body.read)
            )
            response.status = 201
            response['Location'] = "#{@doc_route}/#{new_photo.id}"
            { message: 'Photo saved', data: new_photo }.to_json
          rescue CreatePhoto::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue CreatePhoto::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError => e
            Api.logger.warn "Could not create photo: #{e.message}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on('participants') do
          # PUT api/v1/albums/[album_id]/participants
          routing.put do
            req_data = JSON.parse(routing.body.read)
            participant = AddParticipant.call(
              auth: @auth,
              album: @req_album,
              parti_email: req_data['email']
            )

            { data: participant }.to_json
          rescue AddParticipant::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end

          # DELETE api/v1/albums/[album_id]/participants
          routing.delete do
            req_data = JSON.parse(routing.body.read)
            participant = RemoveParticipant.call(
              auth: @auth,
              parti_email: req_data['email'],
              album_id:
            )

            { message: "#{participant.username} removed from album",
              data: participant }.to_json
          rescue RemoveParticipant::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end
      end

      routing.is do
        # GET api/v1/albums
        routing.get do
          albums = AlbumPolicy::AccountScope.new(@auth_account).viewable

          JSON.pretty_generate(data: albums)
        rescue StandardError
          routing.halt 403, { message: 'Could not find any albums' }.to_json
        end

        # POST api/v1/albums
        routing.post do
          new_data = JSON.parse(routing.body.read)
          new_album = CreateAlbumForOwner.call(
            auth: @auth, album_data: new_data
          )

          response.status = 201
          response['Location'] = "#{@album_route}/#{new_album.id}"
          { message: 'Album saved', data: new_album }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          routing.halt 400, { message: 'Illegal Request' }.to_json

        rescue CreateAlbumForOwner::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json

        rescue StandardError => e
          Api.logger.error "Unknown error: #{e.message}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
