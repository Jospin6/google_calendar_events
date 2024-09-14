class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.string :title
      t.datetime :start_time
      t.datetime :end_time
      t.string :calendar_name
      t.string :google_event_id
      t.references :user, null: false, foreign_key: true
      t.string :venue
      t.text :description
      t.string :guest_list
      t.string :city
      t.string :state
      t.string :country
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
