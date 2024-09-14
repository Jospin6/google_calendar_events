module GoogleCalendarApi
    BASE_URL = 'https://www.googleapis.com/calendar/v3'
  
    def get_google_calendar_client(current_user)
      return unless current_user&.access_token
  
      @access_token = current_user.access_token
    end
  
    def create_google_event(event)
      g_event = get_event(event)
      response = make_request('POST', "/calendars/#{Event::CALENDAR_ID}/events", g_event)
      event.update(google_event_id: response['id']) if response
    end
  
    def edit_google_event(event)
      g_event = get_event(event)
      make_request('PUT', "/calendars/#{Event::CALENDAR_ID}/events/#{event.google_event_id}", g_event)
    end
  
    def delete_google_event(event)
      make_request('DELETE', "/calendars/#{Event::CALENDAR_ID}/events/#{event.google_event_id}")
    end
  
    def get_event(event)
      {
        summary: event.title,
        location: event.venue,
        description: event.description,
        start: {
          dateTime: event.start_date.to_datetime.iso8601,
          timeZone: 'Africa/Nairobi'
        },
        end: {
          dateTime: event.end_date.to_datetime.iso8601,
          timeZone: 'Africa/Nairobi'
        },
        attendees: event_attendees(event),
        reminders: {
          useDefault: false
        },
        sendNotifications: true,
        sendUpdates: 'all'
      }
    end
  
    def make_request(method, path, body = nil)
      uri = URI("#{BASE_URL}#{path}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
  
      request = case method
                when 'GET'
                  Net::HTTP::Get.new(uri)
                when 'POST'
                  req = Net::HTTP::Post.new(uri)
                  req.body = body.to_json
                  req.content_type = 'application/json'
                  req
                when 'PUT'
                  req = Net::HTTP::Put.new(uri)
                  req.body = body.to_json
                  req.content_type = 'application/json'
                  req
                when 'DELETE'
                  Net::HTTP::Delete.new(uri)
                end
  
      request['Authorization'] = "Bearer #{@access_token}"
      response = http.request(request)
  
      JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
    rescue => e
      puts e.message
      nil
    end
  
    def event_attendees(event)
      attendees = event.email_guest_list.map do |guest|
        { email: guest, displayName: guest.split('@').first, organizer: false }
      end
      attendees << { email: event.user.email, displayName: event.user.name, organizer: true }
    end
end