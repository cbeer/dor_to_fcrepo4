$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
ENV['ENV'] ||= 'sul-dor-prod.stanford.edu'
require 'byebug'
require 'dor_to_fcrepo4'
require 'dor4/core'
require 'http_logger'
require 'logger'
HttpLogger.logger = Logger.new("debug-http.log")
HttpLogger.log_headers = true
Rubydora::Repository.logger.level = Logger::WARN
task :migrate do
  coll = Dor.find 'druid:qb438pg7646'
  fcr4col = Dor4::Collection.from_dor_object coll
end
