# require 'rubygems'
# $ rails runner "PoolingGemJob.perform_later"
# $ heroku run rails runner "PoolingGemJob.perform_later" --app bds-max

class PoolingGemJob < ApplicationJob
# class PoolingGemJob < ActiveJob::Base
  # queue_as :default
  def perform
    puts "#{"="*40}\PoolingGemJob - Initialized!"
    # PoolingGem.new.delay.pooling_gem_starter
    # PoolingGem.new.pooling_gem_starter
    PoolingGem.new.pooling_gem_starter

  end

end
############################################

class PoolingGem

  def initialize
    puts "PoolingGem - Initialized!\n#{"="*40}"
    pooling_gem_starter
  end

  def pooling_gem_starter
    array = (0..50).to_a
    puts "PID: #{Process.pid} - In the pooling_gem_starter"

    nested_ids = array.in_groups(10)
    nested_ids.each do |ids|
      delay.nested_iterator(ids)
      # sleep(1)
    end
    # nested_ids.each { |ids| nested_iterator(ids) }
  end

  def nested_iterator(ids)
    # ids.each { |id| template_starter(id) }
    ids.each do |id|
      puts "PID: #{Process.pid} - In the nested_iterator"
      delay.template_starter(id)
      # sleep(1)
    end
  end

  def template_starter(id)
    puts "PID: #{Process.pid} - In the template_starter"
  end

end
