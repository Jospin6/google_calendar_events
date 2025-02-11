class Event < ApplicationRecord
  include GoogleCalendarApi
  CALENDAR_ID = 'primary'
  belongs_to :user
  has_rich_text :description
  after_create :publish_event_to_gcal
  after_update :update_event_on_gcal
  before_destroy :remove_event_from_gcal

  validates :title, :description, :venue, :start_time, :end_time, presence: true
  validate :validate_event_dates
  
  def email_guest_list
    guest_list.present? ? guest_list.split(', ') : [] 
  end

  def validate_event_dates
    return if start_time.nil? || end_time.nil?
    
    if start_time > end_time
      errors.add(:start_time, 'must be less than end date')
    end
  end

  def publish_event_to_gcal
    self.create_google_event(self)
  end

  def update_event_on_gcal
    self.edit_google_event(self)
  end

  def remove_event_from_gcal
    self.delete_google_event(self)
  end
end
