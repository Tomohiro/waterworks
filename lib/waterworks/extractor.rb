require 'open-uri'
require 'fileutils'
require 'mechanize'
require 'nokogiri'

module Waterworks
  class Extractor
    attr_reader :uri

    class << self
      def matches(uri)
        Dir.glob(extractor_file_paths).each do |file|
          require file
          klass = eval(filename_classify(File.basename(file, '.rb'))).new
          next unless klass.match?(uri)
          yield klass
        end
      end

      def filename_classify(filename)
        filename.split('_').map(&:capitalize).join
      end

      def extractor_file_paths
        [File.expand_path("#{ENV['HOME']}/.waterworks/extractors/*.rb")]
      end
    end

    def match?(uri)
      uri =~ /#{domain}/
    end

    def save(uri)
      @uri   = uri
      @agent = agent(@uri)

      mkdir(save_to)
      resources.each do |resource|
        display_resource_info(resource)
        wget(
          resource.source,
          '--referer' => uri,
          '-U'        => "'#{user_agent}'",
          '-O'        => "'#{save_to}/#{resource.destination}'"
        )
      end
    rescue StandardError => e
      abort e.to_s
    end

    protected

    def wget(uri, options = {})
      system("wget #{options.flatten.join(' ')} '#{uri}'")
    end

    def agent(url)
      Nokogiri::HTML(open(url))
    rescue StandardError => e
      abort e.to_s
    end

    def user_agent
      'Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0'
    end

    def save_to
      [store, series, season].compact.join('/')
    end

    # Store the download destination directory
    def store
      @store ||= File.expand_path('~/Downloads')
    end

    # Returns the target domain
    def domain; end

    # Returns the series name
    def series; end

    # Returns the season name
    def season; end

    # Returns the title
    def title; end

    # Return the resource instances
    #
    # @return [Array<Waterworks::Resource>]
    def resources; end

    def http_response_headers(uri, redirect_limit = 5)
      if redirect_limit == 0
        puts "HTTP redirect too deep => #{uri}"
        return uri
      end

      uri = URI.parse(uri)
      headers = {}

      http_request.start(uri.host) do |http|
        headers = http.head(uri.path)
      end

      case headers
      when Net::HTTPOK
        headers
      when Net::HTTPFound
        uri = headers['Location']
        http_response_headers(uri, redirect_limit - 1)
      end

      headers
    end

    def http_request
      proxy_uri = ENV['https_proxy'] || ENV['http_proxy'] || false
      return Net::HTTP unless proxy_uri

      proxy = URI.parse(proxy_uri)
      Net::HTTP::Proxy(proxy.host, proxy.port)
    end

    def file_size(uri)
      file_headers   = http_response_headers(uri)
      file_not_found = 0

      file_headers.fetch('content-length', file_not_found).to_i
    end

    private

    def mkdir(path)
      FileUtils.mkdir_p(path) unless File.directory?(path)
    end

    def display_resource_info(resource)
      puts "Save to: #{save_to}#{resource.destination}"
      puts " Source: #{resource.source}"
      puts "   Size: #{resource.size_mb} MB"
    end
  end
end
