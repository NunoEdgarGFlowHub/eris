# Startup
# std lib
require 'json'

# gems
require 'bundler'
require 'sinatra'
require 'sprockets'
require 'c3d'
require 'epm'
require 'haml'
require './app/eris'

# this app
Dir[File.dirname(__FILE__) + '/bylaws/*.rb'].each {|file| require file }

ERIS_REPO = 'https://github.com/project-douglas/eris.git'

C3D::SetupC3D.new
C3D::ConnectTorrent.supervise_as :puller, {
    username: ENV['TORRENT_USER'],
    password: ENV['TORRENT_PASS'],
    url:      ENV['TORRENT_RPC'] }
C3D::ConnectEth.supervise_as :eth, :cpp

C3D::Utility.save_key
$key = Celluloid::Actor[:eth].get_key

C3D::Utility.save_address
$doug = C3D::Utility.get_latest_doug

if ENV['ETH_REMOTE'] == '173.246.105.207'
  ENV['GAS_PRICE'] = '0'
end

map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path 'app/assets/scripts/bootstrap/dist'
  environment.append_path 'app/assets'
  run environment
end

use Rack::ShowExceptions
run Sinatra::Application