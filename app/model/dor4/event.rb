module Dor4
  class Event < Dor4::Base
    self.prefix = '/rest/:parent_id/'
    belongs_to :object, class_name: "Dor4::Item"
    
    schema do
      attribute :rdf_type, :uri, predicate: RDF.type
      attribute :used_id, :uri, predicate: RDF::URI.new("http://www.w3.org/ns/prov#used")
      attribute :who, :string, predicate: RDF::URI.new("http://www.w3.org/ns/prov#wasStartedBy")
      attribute :endedAtTime, :datetime, predicate: RDF::URI.new("http://www.w3.org/ns/prov#endedAtTime")
    end
    
    class << self
      def from_dor_object parent, obj
        obj.events.find_by_terms(:event).each do |ev|
          e = parent.events.build object: parent
          
          e.rdf_type ||= []
          e.rdf_type << RDF::URI.new("http://www.w3.org/ns/prov#Activity")
          e.rdf_type << RDF::URI.new("http://library.stanford.edu/dlss/dor/event##{ev.attr('type')}")
          e.endedAtTime = Time.parse ev.attr('when')
          e.who = ev.attr('who')
          e.title = ev.text
          e.used_id ||= []
          e.used_id << parent.id
          
          e.save
          e
        end
        
        obj.provenanceMetadata.ng_xml.xpath("//event").each do |ev|
          e = parent.events.build object: parent
          
          e.rdf_type ||= []
          e.rdf_type << RDF::URI.new("http://www.w3.org/ns/prov#Activity")
          e.endedAtTime = Time.parse ev.attr('when')
          e.who = ev.attr('who')
          e.title = ev.text
          e.used_id ||= []
          e.used_id << parent.id
          e.used_id << ev.attr('file') if ev.attr('file')
          
          e.save
          e
        end if obj.provenanceMetadata and obj.provenanceMetadata.respond_to? :ng_xml
      end
    end
    
    def prefix_options
      super.merge(parent_id: object.to_param)
    end

    protected
    def slug
      slug = super
      "events/#{slug || SecureRandom.uuid}"
    end
    
  end
end
