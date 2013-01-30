require 'waterworks/version'

module Waterworks
  require 'waterworks/resource'
  require 'waterworks/extractor'

  def self.run
    uri = ARGV.first
    case uri
    when /himado/
      require 'waterworks/extractors/himado'
      Himado.new(uri).save
    end
  end
end
