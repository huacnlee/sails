require_relative "../lib/sails"

# Force set Sails root to spec/dummy
Sails.root = File.expand_path("../dummy", __FILE__)