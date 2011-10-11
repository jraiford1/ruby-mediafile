require_relative 'mediafile'
require_relative 'metadata_containers'

class Mp4File < MediaFile
  
  def self.supports?(file)
    file.seek(4)
    file.readpartial(4) == "ftyp"
  end
  def read_metadata
    @file.seek(0)
    @boxes = []
    while !(box = MP4Box.open_on(@file)).nil?
      @boxes << box
      @file.seek(box.offset + box.size)
    end
    @metadata_containers = []
  end
end

class MP4Box
  attr_reader :file, :offset, :identifier, :size
  def self.open_on(file)
    return nil if file.eof?
    size = file.read_uint32be
    return nil if size == 0
    self.new(file, size)
  end
  def initialize(file, size)
    @file = file
    @offset = file.pos - 4
    @identifier = file.readpartial(4)
    if size == 1
      @size = file.read_uint64be
    else
      @size = size
    end
  end
end
