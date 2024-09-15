module GoogleCalendarApi
  extend ActiveSupport::Concern

  BASE_URL = 'https://www.googleapis.com/calendar/v3'

  included do
    attr_accessor :access_token
  end

  def initialize_google_client(current_user)
    @access_token = current_user&.access_token
  end

  def create_google_event(event)
    handle_google_event(event, 'POST')
  end

  def edit_google_event(event)
    handle_google_event(event, 'PUT')
  end

  def delete_google_event(event)
    make_request('DELETE', "/calendars/#{Event::CALENDAR_ID}/events/#{event.google_event_id}")
  end

  def get_google_event(event)
    response = make_request('GET', "/calendars/#{Event::CALENDAR_ID}/events/#{event.google_event_id}")
    response if response&.dig('id') == event.google_event_id
  end

  private

  def handle_google_event(event, method)
    g_event = build_event_payload(event)
    response = make_request(method, "/calendars/#{Event::CALENDAR_ID}/events#{method == 'POST' ? '' : "/#{event.google_event_id}"}", g_event)
    event.update(google_event_id: response['id']) if response && method == 'POST'
  end

  def build_event_payload(event)
    {
      summary: event.title,
      location: event.venue,
      description: event.description,
      start: format_time(event.start_date),
      end: format_time(event.end_date),
      attendees: event_attendees(event),
      reminders: { useDefault: false },
      sendNotifications: true,
      sendUpdates: 'all',
      creator: { email: event.user.email }
    }
  end

  def format_time(date)
    {
      dateTime: date.to_datetime.iso8601,
      timeZone: 'Africa/Nairobi'
    }
  end

  def make_request(method, path, body = nil)
    uri = URI("#{BASE_URL}#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = build_request(method, uri, body)
    request['Authorization'] = "Bearer #{@access_token}"

    response = http.request(request)
    JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  rescue => e
    Rails.logger.error(e.message)
    nil
  end

  def build_request(method, uri, body)
    request = case method
              when 'GET'
                Net::HTTP::Get.new(uri)
              when 'POST'
                create_body_request(Net::HTTP::Post.new(uri), body)
              when 'PUT'
                create_body_request(Net::HTTP::Put.new(uri), body)
              when 'DELETE'
                Net::HTTP::Delete.new(uri)
              end
    request
  end

  def create_body_request(request, body)
    request.body = body.to_json
    request.content_type = 'application/json'
    request
  end

  def event_attendees(event)
    event.email_guest_list.map { |guest| attendee_hash(guest, false) } << attendee_hash(event.user.email, true)
  end

  def attendee_hash(email, organizer)
    { email: email, displayName: email.split('@').first, organizer: organizer }
  end
end