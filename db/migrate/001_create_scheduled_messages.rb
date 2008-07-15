class CreateScheduledMessages < ActiveRecord::Migration
  def self.up
    create_table :scheduled_messages do |t|
      t.string :destination_queue, :null  => false
      t.string :schedule_method, :null => false
      t.string :schedule_value, :null => false
      t.text :message, :null => false
      t.boolean :paused, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :scheduled_messages
  end
end
