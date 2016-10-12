class MiqScheduleWorker::Scheduler
  include Vmdb::Logging

  def initialize(*args)
    require 'rufus/scheduler'
    @scheduler = Rufus::Scheduler.new(*args)
  end

  delegate :jobs, :schedule_at, :stop, :to => :@scheduler

  def schedule_every(*args, &block)
    raise ArgumentError if args.first.nil?
    @scheduler.schedule_every(*args, &block)
  rescue ArgumentError => err
    _log.error("#{err.class} for schedule_every with #{args.inspect}.  Called from: #{caller[1]}.")
  end

  def cron(cronline, callable = nil, opts = {}, &block)
    @scheduler.cron(cronline, callable, opts.merge(:job => true), &block)
  end
end
