require 'open-uri'
require 'fileutils'
require 'mechanize'
require 'nokogiri'

module Waterworks
  class Extractor
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

    def initialize(store = '~/Downloads')
      @store = File.expand_path(store)
    end

    def match?(uri)
      uri =~ /#{domain}/
    end

    def save(uri)
      @agent = agent(uri)

      mkdir(save_to)
      resources.each do |resource|
        display_resource_info(resource)
        system("wget -O '#{save_to}#{resource.destination}' '#{resource.source}'")
      end
    rescue Exception => e
      abort e.to_s
    end

    protected
      def agent(url)
        Nokogiri::HTML(open(url))
      rescue Exception => e
        abort e.to_s
      end

      def save_to
        [@store, series, season].join('/')
      end

      # return the domain
      def domain; end

      # return the series name
      def series; end

      # return the season name
      def season; end

      # return the title
      def title; end

      # return the download file path list
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
