module Dor4
  class Core < ActiveResource::Ldp::Base
    require 'dor4/base'
    self.site = "http://localhost:8081/rest"
    require 'dor4/item'
    require 'dor4/collection'
    require 'dor4/content'
    require 'dor4/event'
  end
end
