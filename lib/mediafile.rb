require 'set'

class MediaFile
  attr_accessor :file
  @@implementations = []
  
  # Classes that need to be implemented by subclasses
  def self.supports?(file)
    false
  end
  # -------------------------------------------------
  
  
  # Time to get clever.  When creating a new instance of a MediaFile, we actually want to return an object
  # based on the subclass that deals with the file type in question.  Also, we don't want to create new files (yet?)
  class << self
    alias :new_prim :new
  end
  def self.new(*args)
    raise "No filename given" if args.size == 0
    filename = args[0]
    raise "File does not exist" if !File.exists?(filename)
    file = File.new(*args)
    childclass = @@implementations.detect {|cls| cls.supports?(file)}
    if childclass.nil?
      file.close
      raise "File type is not supported" 
    end
    child = childclass.new_prim
    child.file = file
    child
  end
  
  def self.inherited(child)
    @@implementations << child
    puts "Added #{child}"
  end
  def self.implementations
    @@implementations
  end
  def metadata_containers
    self.get_metadata_containers if @metadata_containers.nil?
    @metadata_containers
  end
  def streams
    self.get_streams if @streams.nil?
    @streams
  end

end
