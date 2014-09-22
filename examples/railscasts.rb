class Railscasts < Waterworks::Extractor
  def domain
    'http://railscasts.com'
  end

  def series
    'RailsCasts'
  end

  def title
    @agent.search('h1').text
  end

  def resources
    video_uri  = video_location
    video_size = file_size(video_uri)

    [Waterworks::Resource.new(uri: video_uri, name: title, suffix: '.mp4', size: video_size)]
  end

  private
    def video_location
      @agent.search('.downloads/li/a').each do |a|
        uri = a.attributes['href'].text
        return uri if uri =~ /mp4$/
      end
    end
end
