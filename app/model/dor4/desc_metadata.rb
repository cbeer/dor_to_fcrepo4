require 'tempfile'
module Dor4
  class DescMetadata < Dor4::Core
    self.prefix = '/rest/:parent_id/descMetadata'
    schema do
      attribute :rdf_type, :uri, predicate: RDF.type
    end

    class MODS < ActiveResource::Ldp::Binary
      self.site = "http://localhost:8081/rest/" 
      self.prefix = '/rest/:parent_id/descMetadata/fcr:content'
      belongs_to :datastream, class_name: "Dor4::DescMetadata"
      
      def prefix_options
        super.merge(datastream.prefix_options).merge(content: ":content")
      end
      protected
      # Create (i.e., \save to the remote service) the \new resource.
      def create
        # get an id
        # POST mixed/multipart
        # update ids
        run_callbacks :create do
          connection.put(collection_path, encode, self.class.headers.merge(instance_create_headers)).tap do |response|
            self.id = collection_path
            #load_attributes_from_response(response)
          end
        end
      end
      
      def instance_create_headers
        { "Content-Type" => "text/turtle" }
      end
      
    end
    
    class << self
      def from_dor_object parent, obj
        md = parent.build_descMetadata object: parent
        md.rdf_type ||= []
        md.rdf_type << RDF::URI("http://projecthydra.org/ns#descMetadata")
        input = Tempfile.new "mods-to-transform.xml"
        input.write obj.content
        input.rewind
        mods_rdf = %x{ saxon -s:#{input.path} -xsl:/Users/cabeer/tmp/modsrdf.xsl | rdf serialize --input-format rdfxml  --output-format ttl }
        mods_rdf.gsub!(":MODS123456", "<" + parent.uri.to_s + ">")
        mods_rdf.gsub!(/(\s):/, "\\1modsrdf:")
        input.close
        input.unlink
        
        md.build_content content: mods_rdf, datastream: md
        md.save
      end
    end

    belongs_to :object, class_name: "Dor4::Item"
    has_content class_name: "Dor4::DescMetadata::MODS"
    
    def prefix_options
      super.merge(parent_id: object.to_param)
    end
    protected
    # Create (i.e., \save to the remote service) the \new resource.
    def create
      # get an id
      # POST mixed/multipart
      # update ids
      content.save
      
      run_callbacks :create do
        connection.put(collection_path, encode, self.class.headers).tap do |response|
          self.id = collection_path
          #load_attributes_from_response(response)
        end
      end
    end
    
  end
end
