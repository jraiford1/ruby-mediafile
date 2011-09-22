require_relative 'mediafile'
require_relative 'metadata_containers'

class Mp3File < MediaFile
  def self.supports?(file)
    File.extname(file.path) =~ /.[mM][pP]3/
  end
  def get_metadata_containers
    containers = ID3.implementations.collect {|imp|
      self.get_container(imp) }
    containers.select! {|tag| !tag.nil?}
    @metadata_containers = containers
  end
  def get_streams
    containers = ID3.implementations.collect {|imp|
      self.get_container(imp) }
    containers.select! {|tag| !tag.nil?}
    @metadata_containers = containers
  end
end
