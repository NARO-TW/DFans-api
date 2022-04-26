# frozen_string_literal: true

require 'roda'
require 'json'

module DFans
  # Web controller for DFans API
  class Api < Roda
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'DFans up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'accounts' do
          @account_route = "#{@api_root}/accounts"

          routing.on String do |username|
            # GET api/v1/accounts/[username]
            routing.get do
              account = Account.first(username: username)
              account ? account.to_json : raise('Account not found')
            rescue StandardError
              routing.halt 404, { message: error.message }.to_json
            end
          end

          # POST api/v1/accounts
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_account = Account.new(new_data)
            raise('Could not save account') unless new_account.save

            response.status = 201
            response['Location'] = "#{@account_route}/#{new_account.id}"
            { message: 'Account created', data: new_account }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT:: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError => e
            Api.logger.error 'Unknown error saving account'
            routing.halt 500, { message: e.message }.to_json
          end
        end

        routing.on 'albums' do
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

              # GET api/v1/albums/[album_id]/photos  OK
              routing.get do
                output = { data: Album.first(id: album_id).photos }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Could not find photos'
              end
              
              # POST api/v1/albums/[album_id]/photos  updated 220422
              routing.post do
                new_data = JSON.parse(routing.body.read)
                # Reuse the service Object as P.17. 10-User Account. 220427
                new_pho = CreatePhotoForAlbum.call(
                  album_id: album_id, photo_id: new_data
                )
                # album = Album.first(id: album_id)
                # new_pho = album.add_photo(new_data)
                # raise 'Could not save photo' unless new_pho

                response.status = 201
                response['Location'] = "#{@pho_route}/#{new_pho.id}"
                { message: 'Photo saved', data: new_pho }.to_json
              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
                routing.halt 400, { message: 'Illegal Attributes' }.to_json
              rescue StandardError => e
                routing.halt 500, { message: e.message }.to_json
              end
            end
            # this block of code is edition '220408'
            #   # POST api/v1/albums/[album_id]/photos
            #   routing.post do
            #     new_data = JSON.parse(routing.body.read)
            #     album = Album.first(id: album_id)
            #     new_photo = album.add_phoument(new_data)
                
            #     if new_photo
            #       # Create(Upload) a new photo
            #       response.status = 201
            #       response['Location'] = "#{@pho_route}/#{new_photo.id}"
            #       { message: 'Photo saved', data: new_photo }.to_json
            #     else
            #       routing.halt 400, 'Could not save the photo uploaded'
            #     end

            #   rescue StandardError
            #     routing.halt 500, { message: 'Database error' }.to_json
            #   end
            # end

            # GET api/v1/albums/[ID]
            routing.get do
              album = Album.first(id: album_id)
              album ? album.to_json : raise('Album not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # GET api/v1/albums
          routing.get do
            output = { data: Album.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find albums' }.to_json
          end

          # POST api/v1/albumects   edition 220417 (this block of code is revised)
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
  end
end
