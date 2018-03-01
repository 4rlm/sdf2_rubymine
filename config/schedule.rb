set :output, "#{path}/log/cron.log"

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# every :sunday, at: "4:28 AM" do
#   runner "Cart.clear_abandoned"
#   Start.sampler
# end

# every :reboot do
#   rake "ts:start"
# end

every 1.second do
  runner "Start.sampler"
end

every 1.second do
  command "echo 'Adam is Awesome!'"
end
