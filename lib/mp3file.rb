require_relative 'mediafile'
require_relative 'metadata_containers'

class Mp3File < MediaFile
  attr_reader :id3v1, :id3v2, :ape
  
  def self.supports?(file)
    File.extname(file.path) =~ /.[mM][pP]3/
  end
  def read_metadata
    @id3v1 = ID3v1Container.open_on(file)
    @id3v2 = ID3v2Container.open_on(file)
    # @ape = APEContainer.open_on(file)
    
    @metadata_containers = []
    @metadata_containers << @id3v1 if !@id3v1.nil?
    @metadata_containers << @id3v2 if !@id3v2.nil?
    @metadata_containers << @ape   if !@ape.nil?
  end
end
