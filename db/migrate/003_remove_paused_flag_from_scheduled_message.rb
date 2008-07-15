class RemovePausedFlagFromScheduledMessage < ActiveRecord::Migration
  def self.up
    remove_column :scheduled_messages, :paused
  end

  def self.down
    add_column :scheduled_messages, :paused, :default => false
  end
end
