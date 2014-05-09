class Dor4::DescMetadata < ActiveResource::Ldp::Base
  self.site = "http://localhost:8080/rest"
  
  has_content MODS::XML
end
