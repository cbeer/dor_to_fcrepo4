class Dor4::Item < Dor4::Base
  belongs_to :collection, class_name: "Dor4::Collection"
  has_many :contents, class_name: "Dor4::Content"
  has_many :events, class_name: "Dor4::Event"
  
  schema do
    attribute :collection_id, :uri, predicate: RDF::URI.new("http://fedora.info/definitions/v4/rels-ext#isMemberOfCollection")
    attribute :workflow_uri, :uri, predicate: RDF::URI.new("http://library.stanford.edu/dlss/dor#hasWorkflowStatus")
    attribute :seeAlso, :uri, predicate: RDF::URI("http://www.w3.org/2000/01/rdf-schema#seeAlso")
  end

  class << self
    def from_dor_object obj
      fcr = new 
      Faraday.delete("http://localhost:8081/rest/" + DruidTools::Druid.new(obj.pid).tree.join("/"))
      fcr.id = DruidTools::Druid.new(obj.pid).tree.join("/")
      
      fcr.pid = obj.pid
      
      obj.dc.class.terminology.terms.keys.each do |t|
        if RDF::DC.respond_to? t
          fcr.send("#{t}=", obj.dc.send(t)) unless obj.dc.send(t).blank? 
        end
      end
      
      (Dor::IdentityMetadataDS.terminology.terms.keys - [:identityMetadata]).each do |t|
        fcr.send("#{t}=", obj.identityMetadata.send(t)) unless obj.identityMetadata.send(t).blank? 
      end
      
      fcr.workflow_uri = obj.workflows.dsLocation
      
      fcr.license = obj.rightsMetadata.ng_xml.xpath("//copyright/human").map { |x| x.text }
      fcr.rights = obj.rightsMetadata.ng_xml.xpath("//use/human[@type='useAndReproduction']").map { |x| x.text }
      
      fcr.save
      
      Dor4::DescMetadata.from_dor_object fcr, obj.descMetadata

      fcr.seeAlso ||= []
      fcr.seeAlso += fcr.descMetadata.content.id

      if obj.contentMetadata
        Dor4::Content.from_dor_object fcr, obj, obj.contentMetadata
      end
      
      Dor4::Event.from_dor_object fcr, obj
      
      
      fcr
    end
  end
  
end
