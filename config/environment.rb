$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../app/model'))

require "config/environments/#{ENV['ENV']}"


RestClient.enable Rack::Cache,
                  verbose: true,
                  default_ttl: 1000000,
                  :metastore => "file:#{File.expand_path("../../tmp/meta", __FILE__)}", 
                  :entitystore => "file:#{File.expand_path("../../tmp/entity", __FILE__)}"
