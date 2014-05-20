module Dor4
  class Content < Dor4::Core
    self.prefix = '/rest/:parent_id/'

    class File < Dor4::Core
      belongs_to :object, class_name: "Dor4::Content"
      
      class Binary < ActiveResource::Ldp::Binary
        belongs_to :datastream, class_name: "Dor4::Content::File"
        self.site = "http://localhost:8081/rest/"
        self.prefix = '/rest/:object_path/:datastream_id/fcr:content'
        
        schema do
          attribute "mimeType", :string
        end
        
        def prefix_options
          super.merge(content: ":content", object_path: datastream.object.to_param, datastream_id: datastream.id)
        end

        def instance_create_headers
          { "Content-Type" => mimeType || "application/octet-stream" }
        end
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
        
      end

      self.prefix = '/rest/:parent_id/'
      has_content class_name: "Dor4::Content::File::Binary"

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
          connection.put(element_path + slug, encode, self.class.headers).tap do |response|
            self.id = slug
          end
        end
      end
      
    end
    
    class << self
      def from_dor_object parent, fcrobj, obj
        obj.ng_xml.xpath("//resource").each do |r|
          cm = parent.contents.build title: r.xpath("label").text, 
                                     id: r.xpath("@id").text,
                                     sequence: r.xpath("@sequence").text,
                                     object: parent
                                     
          cm.rdf_type ||= []
          cm.rdf_type << RDF::URI.new("http://library.stanford.edu/dlss/dor#Content")                          
          
          r.xpath('//file').each do |f|
            file = cm.files.build id: f.xpath("@id").text, object: cm
            techmd = fcrobj.technicalMetadata.ng_xml.xpath("//file[@id='#{file.id}']").first
            techmd.elements.each do |c|
              
              case
              when c.elements.empty?
                name = "#{c.namespace.prefix}_#{c.name}"
                uri = "#{c.namespace.href}\##{c.name}"
                
                file.schema[name] ||= { type: :string, predicate: RDF::URI(uri) }
                file.send("#{name}=", c.text)
              when (c.elements.map { |x| x.name }.uniq.length == 1  &&
                c.elements.none? { |x| x.elements.any? }
                )
                c.elements.each do |c1|
                  name = "#{c.namespace.prefix}_#{c1.name}"
                  uri = "#{c.namespace.href}\##{c1.name}"
                  
                  file.schema[name] ||= { type: :string, predicate: RDF::URI(uri) }
                  file.send("#{name}=", c1.text)
                end
              else
                name = "#{c.namespace.prefix}_#{c.name}"
                uri = "#{c.namespace.href}\##{c.name}"
                
                file.schema[name] ||= { type: :string, predicate: RDF::URI(uri) }
                doc2 = Nokogiri::XML('')
                doc2.root = c
                file.send("#{name}=", doc2.to_xml)
              end
            end
            file.build_content content: Faraday.get("https://stacks.stanford.edu/file/#{obj.pid}/#{file.id}").body, datastream: file, mimeType: f.xpath("@mimetype").text
          end
          cm.save
        end
      end
    end
    
    belongs_to :object, class_name: "Dor4::Item"
    has_many :files, class_name: "Dor4::Content::File"
    
    def prefix_options
      super.merge(parent_id: object.to_param)
    end
    
    schema do
      attribute :rdf_type, :uri, predicate: RDF.type
      attribute "title", :string, predicate: RDF::DC.title
      attribute "sequence", :integer, predicate: RDF::URI.new("info:seqNum")
    end
    
    protected
    
    protected
    # Create (i.e., \save to the remote service) the \new resource.
    def create
      run_callbacks :create do
        connection.put(collection_path + slug, encode, self.class.headers).tap do |response|
          self.id = collection_path + slug
          load_attributes_from_response(response)
        end
      end
    end
    
    
    def slug
      "contents/#{id}" if id
    end
  end
end
