class AddJobIdToScheduledMessage < ActiveRecord::Migration
  def self.up
    add_column :scheduled_messages, :job_id, :integer, :null => true
  end

  def self.down
    remove_column :scheduled_messages, :job_id
  end
end
