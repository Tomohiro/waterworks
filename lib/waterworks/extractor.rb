require 'open-uri'
require 'mechanize'
require 'nokogiri'

module Waterworks
  class Extractor
    def initialize(url, store = '~/Downloads')
      @agent = agent(url)
      @store = File.expand_path(store)
    end

    def save
      mkdir(save_to)
      resources.each do |resource|
        display_resource_info(resource)
        system("wget -O '#{save_to}#{resource.destination}' '#{resource.source}'")
      end
    end

    protected
      def agent(url)
        Nokogiri::HTML(open(url))
      end

      def save_to
        "#{@store}/#{series}/#{season}"
      end

      # return the series name
      def series; end

      # return the season name
      def season; end

      # return the title
      def title; end

      # return the download file path list
      def resources; end

      def http_response_headers(uri, redirect_limit = 5)
        raise ArgumentError, 'HTTP redirect too deep' if redirect_limit == 0
  
        uri = URI.parse(uri)
        headers = {}

        Net::HTTP.start(uri.host) do |http|
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

    private
      def mkdir(path)
        Dir.mkdir(path) unless File.directory?(path)
      end

      def display_resource_info(resource)
        puts "Save to: #{save_to}#{resource.destination}"
        puts " Source: #{resource.source}"
        puts "   Size: #{resource.size_mb} MB"
      end
  end
end
