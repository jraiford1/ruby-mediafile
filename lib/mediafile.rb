require 'set'

class MediaFile < File
  @@implementations = Hash.new
    def self.inherited(child)
      if child.is_implementation?
        @@implementations[child.name_regexp] = child
        puts "Added #{child}"
      end
    end
end
