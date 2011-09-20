require 'set'

module ID3Tag
  
  @@implementations = SortedSet.new
  class ID3
    
    # load each id3v2 tag implementation
    def self.load_implementations
      Dir.glob(File.dirname(__FILE__) + '/id3v2_*', &method(:require))
    end
    def self.implementations
      @@implementations
    end
    def self.<=> other
      self.version <=> other.version      
    end
    def self.version
      raise "Subclass does not implement method"
    end
    def self.gettags(io)
      tags = @@implementations.reverse_each.collect {|cls| cls.gettag(io)}
      tags.select! {|tag| !tag.nil?}
      tags
    end
    def self.gettag(io)
      io.seek(0)
      bytes = io.read(self.header_size)
      return nil if self.header_regexp.match(bytes).nil?
      self.new(bytes, io)      
    end
  end
end

require 'id3tag/id3v1'
require 'id3tag/id3v2'