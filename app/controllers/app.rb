# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/photo'

module DFans
  # Web controller for DFans API
  class Api < Roda
    plugin :halt

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json' # it behave like a Hash #Set Http response Header as 'application/json'

      routing.root do # Leverage the object 'routing' inherit from Roda
        response.status = 200
        { message: 'DFans up at /api/v1' }.to_json # Hash it , then convert it into json, send the body of json back to client
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'photos' do
            # GET api/v1/photos/[id]
            routing.get String do |id|
              response.status = 200
              # Call the Photo model to find the doc with the specific ID, and convert it into Json
              Photo.find(id).to_json
            rescue StandardError
              # if any error happens in these block, 'halt' this request and show 'Photo not found'
              routing.halt 404, { message: 'Photo not found' }.to_json
            end

            # GET api/v1/photos
            routing.get do
              response.status = 200
              output = { Photo_ids: Photo.all } 
              JSON.pretty_generate(output)
            end

            # POST api/v1/photos
            routing.post do
              new_data = JSON.parse(routing.body.read) # read the bbody of whole string and parse it into JSON
              new_doc = Photo.new(new_data)

              if new_doc.save
                response.status = 201 # 201 =>means create sth for you
                { message: 'Photo saved', id: new_doc.id }.to_json
              else
                routing.halt 500, { message: 'Could not save photo' }.to_json
              end
            end
          end
        end
      end
    end
  end
end
