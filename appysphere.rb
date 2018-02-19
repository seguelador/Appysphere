require 'byebug'

class LogFileParser
  def initialize file_path
    raise ArgumentError unless File.exists?(file_path)
    @file_path = file_path

    # Define URLs in array
    @urls = [
      { name: 'get_camera', method: 'GET', path: '/api/users/(.*?)/get_camera' },
      { name: 'get_all_cameras', method: 'GET', path: '/api/users/(.*?)/get_all_cameras' },
      { name: 'get_home' ,method: 'GET', path: '/api/users/(.*?)/get_home' },
      { name: 'post_users', method: 'POST', path: '/api/users/(.*?)' }
    ]
  end

  # Number of times every camera was called segmented per home
  def camera_called_per_home
    # Open File
    log             = File.open(@file_path)

    # Get urls which will be used from array of @urls
    get_camera      = @urls.find { |u| u[:name] == 'get_camera' }
    get_all_cameras = @urls.find { |u| u[:name] == 'get_all_cameras' }

    # Get lines with specific urls
    lines           = log.find_all { |line| line =~ /#{get_camera[:path]}/ || line =~ /#{get_all_cameras[:path]}/ }

    # Make a hash for counting default to 0 so that += will work
    result          = Hash.new(0)

    # Iterate over the array, counting duplicate entries
    lines.each do |line|
      result[line[/home_id=(.*?) /, 1]] += 1
    end
    print result

    # File close
    log.close
  end

  # Mean, median and mode of the repsponse time (connect + service times) for urls
  def response_time_metrics
    result = {}
    @urls.each do |url|
      result[url[:name]] = get_metrics(url[:path])
    end
    print result
  end

  # Ranking of the devices per service time
  def devices_ranking
    result = {}
    # Open File
    log = File.open(@file_path)

    get_camera = @urls.find { |u| u[:name] == 'get_camera' }
    lines = log.find_all { |line| line =~ /#{get_camera[:path]}/ }

    # Iterate over the array adding to hash {ip: service time}
    lines.each do |line|
      result[line[/ip_camera=(.*?) /, 1]] = line[/service=(.*?)ms /, 1].to_i
    end

    # Sort by service time
    result = result.sort_by { |k, v| v }.to_h

    print result

    # File close
    log.close
  end

  private
    def get_metrics path
      log              = File.open(@file_path)
      metric           = {}
      lines            = log.find_all { |line| line =~ /#{path}/ }
      response_times   = lines.map { |line| line[/service=(.*?)ms /, 1].to_i + line[/connect=(.*?)ms /, 1].to_i }
      metric[:average] = "#{mean(response_times)}ms"
      metric[:median]  = "#{median(response_times)}ms"
      metric[:mode]    = mode(response_times)

      # File close
      log.close
      metric
    end

    # Methods for Mean, Median and Mode, also could extend Array Class
    def mean array
      array.inject(:+).to_f / array.length.to_f
    end

    def median array
  	  array = array.sort
  	  m_pos = array.length / 2
  	  array.size % 2 == 1 ? array[m_pos] : mean(array[m_pos-1..m_pos])
  	end

    # Obtained from https://stackoverflow.com/questions/26249611/finding-the-mode-of-an-array-in-ruby
    # More info how it works in link above
    def mode array
      hash = Hash.new(0)
      array.each { |i| hash[i]+=1 }
      hash
    end
end
