$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../app/model'))

require "config/environments/#{ENV['ENV']}"


RestClient.enable Rack::Cache,
                  verbose: false,
                  default_ttl: 100000,
                  allow_revalidate: false,
                  allow_reload: false,
                  :metastore => "file:#{File.expand_path("../../tmp/meta", __FILE__)}", 
                  :entitystore => "file:#{File.expand_path("../../tmp/entity", __FILE__)}"
