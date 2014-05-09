module Dor4
 class Base < ActiveResource::Ldp::Base
    require 'dor4/desc_metadata'

    has_child 'descMetadata', class_name: "Dor4::DescMetadatas"

    self.site = "http://localhost:8080/rest"
    require 'dor4/item'
    require 'dor4/collection'
    schema_from_vocabulary RDF::DC
    
    schema do |s|
      attribute 'pid', :string, predicate: "info:fedora/fedora-system:def/foxml#PID"
      (Dor::IdentityMetadataDS.terminology.terms.keys - [:identityMetadata]).each do |t|
        attribute t, :string, predicate: RDF::URI.new("http://library.stanford.edu/dlss/dor/identity##{t}")
      end
      attribute 'event', :string, predicate: 'http://library.stanford.edu/dlss/dor/event'
    end
  end
end
