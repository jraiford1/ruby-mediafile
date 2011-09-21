require 'set'
require_relative 'mediafile'

  class ID3File < MediaFile
    def self.is_implementation?
      false
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
