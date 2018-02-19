require 'byebug'

class LogFileParser
  def initialize file_path
    raise ArgumentError unless File.exists?(file_path)
    @log = File.open(file_path)

    # URLs
    @get_camera      = { method: 'GET', end_path: '/get_camera' }
    @get_all_cameras = { method: 'GET', end_path: '/get_all_cameras' }
  end

  # Number of times every camera was called segmented per home
  def camera_called_per_home
    # Get lines with specific urls
    lines  = @log.find_all { |line| line =~ /#{@get_camera[:end_path]}/ || line =~ /#{@get_all_cameras[:end_path]}/ }
    # Make a hash for counting
    result = Hash.new(0)

    lines.each do |line|
      result[line[/home_id=(.*?) /, 1]] += 1
    end

    result.each do |k, v|
      puts "Home with id: #{k} has #{v} camera calls"
    end
  end
end
