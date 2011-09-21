require 'set'

class MediaFile < File
  @@implementations = []
    # Time to get clever.  When creating a new instance of a MediaFile, we actually want to return an object
    # based on the subclass that deals with the file type in question.  Also, we don't want to create new files (yet?)
    class << self
      alias :new_prim :new
    end
    def self.new(*args)
      raise "No filename given" if args.size == 0
      filename = args[0]
      childclass = @@implementations.detect {|cls| cls.supports(filename)}
      raise "File type is not supported" if childclass.nil?
      childclass.new_prim(filename, *args)
    end
    
    def self.supports(filename)
      false
    end
    
    def self.inherited(child)
      @@implementations << child
      puts "Added #{child}"
    end
    def self.implementations
      @@implementations
    end
end
