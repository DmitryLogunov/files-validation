# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 0) do

  create_table "kkAddress", force: true do |t|
    t.string  "address"
    t.string  "city"
    t.integer "timeZone"
    t.string  "street"
    t.string  "house",     limit: 10
    t.string  "building",  limit: 10
    t.string  "structure", limit: 10
    t.string  "apartment", limit: 10
    t.string  "KLADR",     limit: 25
  end

  create_table "kkTypeVehicleGroup", force: true do |t|
    t.string  "uid",                  limit: 36, null: false
    t.string  "vehicleGroupTypeName"
    t.string  "trailerTypeUID",       limit: 36
    t.string  "trailerTypeName"
    t.string  "tonnageUID",           limit: 36
    t.string  "volumeUID",            limit: 36
    t.boolean "markedDelete"
    t.string  "code"
  end

  create_table "kkVehicleGroups", force: true do |t|
    t.string "raceUID",             limit: 36
    t.string "typeVehicleGroupUID", limit: 36
  end

  create_table "kkTypeTrailers", force: true do |t|
    t.string  "uid",          limit: 36, null: false
    t.string  "name"
    t.string  "code",         limit: 5
    t.boolean "markedDelete"
  end
end
