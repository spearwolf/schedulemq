require 'schedulemq'

class ScheduledMessage < ActiveRecord::Base

  SCHEDULE_METHODS = %w(in at every cron)

  validates_presence_of :destination_queue
  validates_inclusion_of :schedule_method, :in => SCHEDULE_METHODS
  validates_presence_of :schedule_value
  validates_presence_of :message

  after_create :schedule
  after_destroy :unschedule

  private

  def schedule
    self.job_id = schedule_server.schedule_message(schedule_method, schedule_value, id)
    update

  rescue Exception => e
    logger.error "Couldn't schedule ScheduledMessage[#{id}]: #{e}"
  end

  def unschedule
    schedule_server.unschedule(job_id) unless job_id.nil?

  rescue Exception => e
    logger.warn "Couldn't unschedule ScheduledMessage[#{id}]: #{e}"
  end

  class << self

    def schedule_server
      $scheduleMQConfig ||= ScheduleMQ::Config.new
      DRbObject.new(nil, "druby://#{$scheduleMQConfig.host}:#{$scheduleMQConfig.port}")
    end

    def schedule_server_alive?
      schedule_server.alive?
    rescue Exception => e
      logger.error(e)
      false
    end
  end
end
