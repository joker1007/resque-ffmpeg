require "resque"

$spec_dir = File.dirname(File.expand_path(__FILE__))

if !system("which redis-server")
  puts '', "** can't find `redis-server` in your path"
  abort ''
end

RSpec.configure do |config|
  config.before(:suite) do
    puts "Starting redis for testing at localhost:9736..."
    `redis-server #{$spec_dir}/redis-test.conf`
    Resque.redis = 'localhost:9736'
  end

  config.after(:suite) do
    processes = `ps -A -o pid,command | grep [r]edis-test`.split($/)
    pids = processes.map { |process| process.split(" ")[0] }
    puts "Killing test redis server..."
    pids.each { |pid| Process.kill("TERM", pid.to_i) }
    system("rm -f #{$dir}/dump.rdb #{$dir}/dump-cluster.rdb")
  end
end

def sample_dir
  File.join(File.dirname(File.expand_path(__FILE__)), "samples")
end

def perform_job(klass, *args)
  resque_job = Resque::Job.new(:testqueue, 'class' => klass, 'args' => args)
  resque_job.perform
end
