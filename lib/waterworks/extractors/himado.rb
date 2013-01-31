class Himado < Waterworks::Extractor
  def series
    @agent.search('span#seriestag/a').text
  end

  def title
    @agent.search('#movie_title').text
  end

  def resources
    resources = []
    movie_mirror_locations do |movie_uri|
      puts "Found source: #{movie_uri}"

      size = movie_size(movie_uri)
      puts " checking size... #{(size / 1024 / 1024)}"

      if high_definition?(size)
        return [Waterworks::Resource.new(title, movie_uri, '.m4v', size)]
      end
    end
    resources
  end

  private
    def movie_mirror_locations
      @agent.search('#select_othersource/option').each do |option|
        agent("http://himado.in/#{option.attributes['value']}").search('script').each do |js|
          next unless js.text =~ /display_movie_url = '(?<movie>.+)';/

          movie_uri = URI.unescape($~[:movie])
          headers = http_response_headers(movie_uri)

          yield headers['Location'] || movie_uri
        end
      end
    end

    def movie_size(uri)
      headers = http_response_headers(uri)
      movie_source_not_found = 0

      headers.fetch('content-length', movie_source_not_found).to_i
    end

    def high_definition?(movie_size)
      high_definition_size_min = 1024 * 1024 * 150 # 150MB
      movie_size > high_definition_size_min
    end
end
