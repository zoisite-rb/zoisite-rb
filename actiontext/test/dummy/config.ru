# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Zoisite.application
Zoisite.application.load_server
