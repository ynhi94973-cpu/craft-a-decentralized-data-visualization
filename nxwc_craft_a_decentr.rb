# nxwc_craft_a_decentr.rb
# A decentralized data visualization controller

require 'sinatra'
require 'json'
require 'securerandom'

# Configuration
VIZ_HOST = 'localhost'
VIZ_PORT = 8080
NODES = ['node1.example.com', 'node2.example.com', 'node3.example.com']

# Data storage
DATA_STORE = {}

# Node connection manager
NODE_CONNECTIONS = {}

# Initialize node connections
NODES.each do |node|
  NODE_CONNECTIONS[node] = Faraday.new("http://#{node}:8080")
end

# API endpoints
post '/data' do
  # Receive data from clients and store it
  data = JSON.parse(request.body.read)
  DATA_STORE[data[:id]] = data[:value]
  status 201
end

get '/data/:id' do
  # Return data for a given ID
  id = params[:id]
  if DATA_STORE.key?(id)
    [200, {'Content-Type' => 'application/json'}, [DATA_STORE[id].to_json]]
  else
    [404, {'Content-Type' => 'application/json'}, ['{"error": "Data not found"}']]
  end
end

post '/viz' do
  # Receive visualization requests and delegate to nodes
  viz_request = JSON.parse(request.body.read)
  node = NODES.sample
  response = NODE_CONNECTIONS[node].post do |req|
    req.url '/viz'
    req.headers['Content-Type'] = 'application/json'
    req.body = viz_request.to_json
  end
  [response.status, {'Content-Type' => 'application/json'}, [response.body]]
end

run Sinatra::Application