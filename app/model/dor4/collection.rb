require 'ruby-progressbar'
require 'parallel'
module Dor4
  class Collection < Dor4::Item
    has_many :items, class_name: "Dor4::Item"

    class << self
      def from_dor_object obj
        fcr = super
        fcr.save
        progress = ProgressBar.create(:title => "Processing", :total => obj.members.length)
        Parallel.each(obj.members, in_processes: 4, finish: lambda { |*args| progress.increment }) do |o|
    #    obj.members.each do |o|
        #   puts o.pid
        #  byebug
           z = Dor4::Item.from_dor_object(o)
           z.collection = fcr
           z.save
        end
        fcr.save
        fcr
      end
    end

    schema do
      
    end
  end
end
