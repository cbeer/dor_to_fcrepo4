class Dor4::Item < Dor4::Base
  belongs_to :collection, class_name: "Dor4::Collection"
  has_many :contents, class_name: "Dor4::Content"
  has_many :events, class_name: "Dor4::Event"
  
  schema do
    attribute :rdf_type, :uri, predicate: RDF.type
    attribute :collection_id, :uri, predicate: RDF::URI.new("http://fedora.info/definitions/v4/rels-ext#isMemberOfCollection")
    attribute :workflow_uri, :uri, predicate: RDF::URI.new("http://library.stanford.edu/dlss/dor#hasWorkflowStatus")
    attribute :seeAlso, :uri, predicate: RDF::URI("http://www.w3.org/2000/01/rdf-schema#seeAlso")
  end

  class << self
    def from_dor_object obj
      fcr = new 
      Faraday.delete( Dor4::Core.site + DruidTools::Druid.new(obj.pid).tree.join("/"))
      fcr.id = DruidTools::Druid.new(obj.pid).tree.join("/")
      
      fcr.pid = obj.pid
      
      unless obj.descMetadata.new?
        input = Tempfile.new "mods-to-transform.xml"
        input.write obj.descMetadata.content
        input.rewind
        mods_rdf = %x{ saxon -s:#{input.path} -xsl:/Users/cabeer/tmp/modsrdf.xsl | rdf serialize --input-format rdfxml  --output-format ttl }
        mods_rdf.gsub!(":MODS123456", "<>").gsub!(/<#([^>]+)>/) { |match| "_:#{$1}"}
        mods_rdf.gsub!(/(\s):/, "\\1modsrdf:")
        
        fcr.graph_to_encode.from_ttl(mods_rdf)
      end

      fcr.rdf_type ||= []
      fcr.rdf_type << RDF::URI("http://projecthydra.org/ns/Dor4#Item")
      obj.class.ancestors.select { |x| x.to_s =~ /^Dor/ }.each do |i|
        fcr.rdf_type << RDF::URI("http://projecthydra.org/ns/Dor##{i.to_s.split("::").last}")
      end
      
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

      if obj.contentMetadata
        Dor4::Content.from_dor_object fcr, obj, obj.contentMetadata
      end
      
      Dor4::Event.from_dor_object fcr, obj
      
      
      fcr
    end
  end
  
end
