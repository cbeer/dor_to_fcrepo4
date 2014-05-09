class Dor4::Collection < Dor4::Item
  has_many :members, class_name: "Dor4::Item"

  class << self
    def from_dor_object obj
      fcr = super
      byebug
    end
  end

  schema do
    
  end
end
