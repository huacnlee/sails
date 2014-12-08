require_relative "../lib/tails"

# Force set Tails root to spec/dummy
Tails.root = File.expand_path("../dummy", __FILE__)