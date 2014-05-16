module Dor4
 class Base < Dor4::Core
    has_child :descMetadata, class_name: "Dor4::DescMetadata"

    schema_from_vocabulary RDF::DC
    
    schema do |s|
      attribute :rdf_type, :uri, predicate: RDF.type
      attribute 'pid', :string, predicate: RDF::URI.new("info:fedora/fedora-system:def/foxml#PID")
      (Dor::IdentityMetadataDS.terminology.terms.keys - [:identityMetadata]).each do |t|
        attribute t, :string, predicate: RDF::URI.new("http://library.stanford.edu/dlss/dor/identity##{t}")
      end
    end
    
    def uri
      if URI(id).relative?
        RDF::URI(self.class.site + id)
      else
        RDF::URI(id)
      end  
    end
  end
end
