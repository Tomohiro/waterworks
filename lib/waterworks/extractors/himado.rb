class Himado < Waterworks::Extractor
  def domain
    'http://himado.in'
  end

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

      size = file_size(movie_uri)
      puts "Checking size: #{(size / 1024 / 1024)} MB"

      if high_definition?(size)
        puts "Found high definition movie"
        return [Waterworks::Resource.new(uri: movie_uri, name: title, suffix: '.m4v', size: size)]
      end
    end
    resources
  end

  private
    def movie_mirror_locations
      @agent.search('#select_othersource/option').each do |option|
        agent("#{domain}/#{option.attributes['value']}").search('script').each do |js|
          next unless js.text =~ /display_movie_url = '(?<movie>.+)';/

          movie_uri = URI.unescape($~[:movie])
          headers = http_response_headers(movie_uri)

          yield headers['Location'] || movie_uri
        end
      end
    end

    def high_definition?(movie_size)
      high_definition_size_min = 1024 * 1024 * 150 # 150MB
      movie_size > high_definition_size_min
    end
end
