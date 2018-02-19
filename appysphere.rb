require 'byebug'

class LogFileParser
  def initialize file_path
    raise ArgumentError unless File.exists?(file_path)
    @file_path = file_path

    # URLs
    @get_camera      = { method: 'GET', path: '/api/users/(.*?)/get_camera' }
    @get_all_cameras = { method: 'GET', path: '/api/users/(.*?)/get_all_cameras' }
    @get_home        = { method: 'GET', path: '/api/users/(.*?)/get_home' }
    @post_users      = { method: 'POST', path: '/api/users/(.*?)' }
  end

  # Number of times every camera was called segmented per home
  def camera_called_per_home
    log = File.open(@file_path)
    # Get lines with specific urls
    lines  = log.find_all { |line| line =~ /#{@get_camera[:path]}/ || line =~ /#{@get_all_cameras[:path]}/ }
    # Make a hash for counting default to 0 so that += will work
    result = Hash.new(0)

    # Iterate over the array, counting duplicate entries
    lines.each do |line|
      result[line[/home_id=(.*?) /, 1]] += 1
    end
    result.each do |k, v|
      puts "Home with id: #{k} has #{v} camera calls"
    end
    log.close
  end

  def response_time_metrics
    result                   = {}
    result[:get_camera]      = get_metrics(@get_camera[:path])
    result[:get_all_cameras] = get_metrics(@get_all_cameras[:path])
    result[:get_home]        = get_metrics(@get_home[:path])
    result[:post_users]      = get_metrics(@post_users[:path])
    print result

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
