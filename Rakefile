$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'byebug'
require 'dor_to_fcrepo4'
require 'dor4/base'
task :migrate do
  coll = Dor.find 'druid:qb438pg7646'
  Dor4::Collection.from_dor_object coll
  #coll.members.each do |obj|
  #  
  #end
end
