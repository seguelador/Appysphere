# Instructions

## List of methods availables
- camera_called_per_home (Number of times every camera was called segmented per home)
- response_time_metrics (Mean, median and mode of the repsponse time (connect + service times) for urls)
- devices_ranking (Ranking of the devices per service time)

### Using ruby console:

`ruby -r "./appysphere.rb" -e "LogFileParser.new('sample_appysphere.log').method_name"`
#### Example:
`ruby -r "./appysphere.rb" -e "LogFileParser.new('sample_appysphere.log').camera_called_per_home"`
