require "CSV"

require "./call"

class CallCollectionGenerator
  def initialize
    @calls = []
  end

  def generate_calls number_of_calls
    total_simulated_seconds = 2880

    talk_range_seconds = 240
    talk_addend_seconds = 180

    number_of_calls.times do
      call_arrive_time = 0 + rand(total_simulated_seconds)
      call_handle_time = 0 + rand(talk_range_seconds) + talk_addend_seconds
      percentile_for_random_decisions = 0 + rand(99) + 1

      call = Call.new(call_arrive_time, call_handle_time, percentile_for_random_decisions)
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

  def write_header_line file
    member_names = "#{Call.members.join(",")}"

    file.syswrite "#{member_names}\n"
  end

  def write_all_calls file
    @calls.each_with_index do |call, index|
      file.syswrite call.to_a.join(",")

      file.syswrite "\n" unless (index == @calls.size - 1)
    end
  end
end

gen = CallCollectionGenerator.new
gen.generate_calls 3000
gen.write_csv_to "test_data/calls_3k_between_8and4.csv"