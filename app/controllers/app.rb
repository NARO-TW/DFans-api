# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/photo'

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
        routing.on 'albums' do
          @album_route = "#{@api_root}/albums"

          routing.on String do |album_id|
            routing.on 'photos' do
              @doc_route = "#{@api_root}/albums/#{album_id}/photos"
              # GET api/v1/albums/[album_id]/photos/[photo_id]
              routing.get String do |photo_id|
                doc = Photo.where(album_ID: album_id, id: photo_id).first
                doc ? doc.to_json : raise('Photo not found')
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
              
              # POST api/v1/projects/[proj_id]/documents
              routing.post do
                new_data = JSON.parse(routing.body.read)
                proj = Album.first(id: proj_id)
                new_doc = proj.add_document(new_data)
                raise 'Could not save photo' unless new_doc

                response.status = 201
                response['Location'] = "#{@doc_route}/#{new_doc.id}"
                { message: 'Photo saved', data: new_doc }.to_json
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
            #     proj = Project.first(id: album_id)
            #     new_photo = proj.add_document(new_data)
                
            #     if new_photo
            #       # Create(Upload) a new photo
            #       response.status = 201
            #       response['Location'] = "#{@doc_route}/#{new_photo.id}"
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

          # POST api/v1/projects   edition 220417 (this block of code is revised)
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_proj = Project.new(new_data)
            raise('Could not save album') unless new_proj.save

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
