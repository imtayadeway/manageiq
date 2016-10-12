RSpec.describe MiqScheduleWorker::Scheduler do
  describe "#jobs" do
    it "returns the scheduled jobs" do
      scheduler = described_class.new
      time = Time.parse("2016-01-01 00:00:00")

      scheduler.schedule_at(time) { "doing some work" }

      expect(scheduler.jobs).to contain_exactly(an_object_having_attributes(:next_time => time))
    end

    it "is empty when there are no jobs" do
      scheduler = described_class.new
      expect(scheduler.jobs).to be_empty
    end
  end

  describe "#schedule_at" do
    it "returns the job" do
      scheduler = described_class.new
      time = Time.parse("2016-01-01 00:00:00")

      job = scheduler.schedule_at(time) { "doing some work" }

      expect(job.next_time).to eq(time)
    end

    it "adds a job to the collection of all jobs" do
      scheduler = described_class.new
      time = Time.parse("2016-01-01 00:00:00")

      expect do
        scheduler.schedule_at(time.to_s) { "doing some work" }
      end.to change { scheduler.jobs.count }.by(1)
    end
  end

  describe "#schedule_every" do
    it "returns the job" do
      Timecop.freeze do
        scheduler = described_class.new

        job = scheduler.schedule_every("3h") { "doing some work" }

        expect(job.next_time).to eq(3.hours.from_now)
      end
    end

    it "adds a job to the collection of all jobs" do
      scheduler = described_class.new

      expect do
        scheduler.schedule_every("3h") { "doing some work" }
      end.to change { scheduler.jobs.count }.by(1)
    end
  end

  describe "#cron" do
    it "returns the job" do
      scheduler = described_class.new

      job = scheduler.cron("0 0 * * *") { "doing some work" }

      expect(job.frequency).to eq(1.day)
    end

    it "adds a job to the collection of all jobs" do
      scheduler = described_class.new

      expect do
        scheduler.cron("0 0 * * *") { "doing some work" }
      end.to change { scheduler.jobs.count }.by(1)
    end
  end
end
