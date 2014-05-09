$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../config'))

require "dor_to_fcrepo4/version"
require 'restclient/components'
require 'rack'
require 'rack/test'
require 'rack/cache'
require 'activeresource/ldp'
require 'dor-services'
require 'environment'

module DorToFcrepo4
end
