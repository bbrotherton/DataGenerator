require "CSV"

INTERVAL_LENGTH = 900
CALLS_PER_INTERVAL = [100,100,100,100,
                      100,100,100,100,
                      220,220,220,220,
                      220,220,220,220,
                      350,350,300,350,
                      300,300,300,300,
                      300,300,300,300,
                      100,100,100,100,
                      100,100,100,100,
                      100,100,100,100]
CALLER_CHOICES = ["hold","callback"]

# arrival_tick,user_choice,handle_time,abandon_tick
Call = Struct.new(
                  :arrival_tick,
                  :user_choice,
                  :handle_time,
                  :abandon_percentile #hold_tolerance_percentile
)

class CallCollectionGenerator
  def initialize
    @calls = []
  end

  def generate_calls calls_per_interval_array, interval_length
    calls_per_interval_array.each_index do |i|
      generate_calls_for_interval calls_per_interval_array[i], i*interval_length+1, i*interval_length+interval_length
    end
  end

  def generate_calls_for_interval number_of_calls, min_tick, max_tick
    total_simulated_seconds = CALLS_PER_INTERVAL.size * INTERVAL_LENGTH
    puts total_simulated_seconds

    talk_range_min_seconds = 4*60
    talk_range_max_seconds = 7*60

    number_of_calls.times do
      call_arrive_time = rand(min_tick..max_tick)
      call_handle_time = rand(talk_range_min_seconds..talk_range_max_seconds)

      caller_choice = CALLER_CHOICES[rand(0..1)]
      abandon_percentile = rand(1..100)

      call = Call.new(call_arrive_time, caller_choice, call_handle_time, abandon_percentile)
      @calls << call
      puts call
    end

    puts @calls.length
  end

  def write_csv_to filepath
    path = filepath
    path = File.join(File.dirname(__FILE__), path) unless path.include? ":"

    @file = File.open(path, 'w')

    write_header_line @file
    write_all_calls @file

    @file.close
  end

  private

  def write_header_line file
    member_names = "#{Call.members.join(",")}"

    file.syswrite "#{member_names}\n"
  end

  def write_all_calls file
    @calls.sort_by!{ |c| c[:arrival_tick] }

    @calls.each_with_index do |call, index|
      file.syswrite call.to_a.join(",")

      file.syswrite "\n" unless (index == @calls.size - 1)
    end
  end

  def get_abandon_tick_by percentile
    case percentile
      when 1..38; 60
      when 39..55; 120
      when 56..62; 180
      when 63..68; 240
      when 69..72; 300
      when 73..78; 420
      when 79..83; 540
      when 84..88; 720
      when 89..92; 960
      when 93..95; 1380
      when 96..98; 2520
      when 99..99; 3600
    end
  end
end

gen = CallCollectionGenerator.new
gen.generate_calls CALLS_PER_INTERVAL, INTERVAL_LENGTH
gen.write_csv_to "test_data/whole_day.csv"