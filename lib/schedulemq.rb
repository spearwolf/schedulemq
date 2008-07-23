# require 'drb'
# require 'stomp'
# require 'rufus/scheduler'
# require 'fastthread'

module ScheduleMQ

  class MasterScheduler

    attr_reader :logger, :config

    class << self

      def start_service(config = Config.new)
        uri = "druby://#{config.host}:#{config.port}"
        puts "Starting ScheduleMQ service at #{uri}"

        DRb.start_service(uri, MasterScheduler.new(config))
        DRb.thread.join
      end

    end # ---------------------------------------------------------------------

    def schedule_message(schedule_method, schedule_value, scheduled_message_id)
      logger.debug "schedule_message(\"#{schedule_method}\", \"#{schedule_value}\", #{scheduled_message_id})"

      real_method = {
        :in    => :schedule_in,
        :at    => :schedule_at,
        :every => :schedule_every,
        :cron  => :schedule
      }[schedule_method.downcase.to_sym]

      job_id = @scheduler.send(real_method, schedule_value) do |job_id, at, params|
        begin
          send_message(scheduled_message_id)

        rescue ActiveRecord::RecordNotFound
          logger.debug "couldn't send message[#{scheduled_message_id}]: not found in database"
          params[:dont_reschedule] = true unless params.nil?

        rescue Exception => unexpected_e
          logger.warn "problem while sending message[#{scheduled_message_id}]: #{unexpected_e}"
          params[:dont_reschedule] = true unless params.nil?
        end
      end

      logger.debug "scheduled_message_id=#{scheduled_message_id} --> job_id=#{job_id}"
      return job_id

    rescue Exception => e
      logger.error "problem while scheduling message[#{scheduled_message_id}]: #{e}"
    end

    def unschedule(job_id)
      logger.debug "unschedule(#{job_id})"
      @scheduler.unschedule(job_id)

    rescue Exception => e
      logger.error "problem while unscheduling job_id[#{job_id}]: #{e}"
    end

    def alive?
      true
    end

    private # -----------------------------------------------------------------

    def initialize config
      @config = config
      @active_record_mutex = Mutex.new
      @logger = config.logger

      @scheduler = Rufus::Scheduler.new
      @scheduler.start

      @message_queue = Queue.new
      start_message_distributor

      logger.info "MasterScheduler started [stomp_server='#{config.stomp_server}', stomp_user:'#{config.stomp_user}']"

      reschedule_persistent_messages
    end

    def reschedule_persistent_messages
      ScheduledMessage.find(:all).each do |m|
        job_id = schedule_message(m.schedule_method, m.schedule_value, m.id)
        @active_record_mutex.synchronize {
          m.update_attribute :job_id, job_id
        }
      end
    end

    def send_message(m_id)
      logger.debug "send_message(#{m_id})"

      m = nil
      @active_record_mutex.synchronize {
        m = ScheduledMessage.find(m_id)
        ScheduledMessage.delete(m) if m.schedule_method =~ /^(in|at)$/i
      }

      distribute_message(m)
    end

    def distribute_message(m)
      @message_queue.enq :queue => m.destination_queue, :body => m.message
    end

    def start_message_distributor
      Thread.new {
        logger.debug 'message distributor started'
        client = create_stomp_client
        loop do
          begin
            m = @message_queue.deq
            logger.debug "send message[\"#{m[:body]}\"] -> '#{m[:queue]}'"
            client.send(m[:queue], m[:body])

          rescue Exception => e
            logger.error "could not send message '#{m[:body]}' to queue '#{m[:queue]}':"
            logger.error e
          end
        end
      }
    end

    def create_stomp_client
      Stomp::Client.new(config.stomp_user, config.stomp_pass, config.stomp_server)

    rescue Exception => e
      logger.error "message distributor died unexpected: #{e}"
      exit 1
    end

  end # MasterScheduler -------------------------------------------------------

  class Config
    def initialize(conf_path = File.join(RAILS_ROOT, 'config', 'schedulemq.yml'))
      @config = YAML.load(ERB.new(IO.read(conf_path)).result)[RAILS_ENV]
    end

    def logger= l
      @logger = l
    end

    def logger
      return @logger unless @logger.nil?
      log_path = @config['log_file'] || File.join(RAILS_ROOT, 'log', "schedulerb_#{RAILS_ENV}.log")
      Logger.new(log_path)
    end

    def method_missing(name, *args, &block)
      @config[name.to_s]
    end
  end

end # ScheduleMQ
