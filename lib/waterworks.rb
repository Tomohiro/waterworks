require 'waterworks/version'

module Waterworks
  require 'waterworks/resource'
  require 'waterworks/extractor'

  def self.run
    case ARGV.first
    when /--version$|-v$/
      puts Waterworks::VERSION
    when /http/
      uri = ARGV.first
      Extractor.matches(uri) do |extractor|
        extractor.save(uri)
      end
    when /--help|-h|help/
      usage
    else
      usage
    end
  end

  def self.usage
    puts File.basename(__FILE__, '.rb')
    puts "      <uri>         # Extract file locations from URI, and download that."
    puts "      --help,    -h # Display help"
    puts "      --version, -v # Display version"
  end
end
