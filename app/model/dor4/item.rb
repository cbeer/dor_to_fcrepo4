class Dor4::Item < Dor4::Base
  belongs_to :collection, class_name: "Dor4::Collection"
  
  class << self
    def from_dor_object obj
      fcr = new 
      fcr.pid = obj.pid
      
      obj.dc.class.terminology.terms.keys.each do |t|
        if RDF::DC.respond_to? t
          fcr.send("#{t}=", obj.dc.send(t)) unless obj.dc.send(t).blank? 
        end
      end
      
      (Dor::IdentityMetadataDS.terminology.terms.keys - [:identityMetadata]).each do |t|
        fcr.send("#{t}=", obj.identityMetadata.send(t)) unless obj.identityMetadata.send(t).blank? 
      end
      
      fcr
    end
  end
  
end
