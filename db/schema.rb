# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 3) do

  create_table "scheduled_messages", :force => true do |t|
    t.string   "destination_queue", :default => "", :null => false
    t.string   "schedule_method",   :default => "", :null => false
    t.string   "schedule_value",    :default => "", :null => false
    t.text     "message",           :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "job_id"
  end

end
