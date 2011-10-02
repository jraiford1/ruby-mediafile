require_relative 'mediafile'
require_relative 'mp3file'
require_relative 'mp4file'
require_relative 'rifffile'

file = MediaFile.new('/home/jon/Music/Parliament/Mothership Connection/05. Handcuffs.mp3')
containers = file.read_metadata
puts file