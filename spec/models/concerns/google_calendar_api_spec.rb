require 'rails_helper'  

RSpec.describe GoogleCalendarApi do  
  let(:dummy_class) { Class.new { include GoogleCalendarApi } }  
  let(:current_user) { double('User', email: 'user@example.com', access_token: 'sample_token') }  
  let(:event) { double('Event', title: 'Test Event', venue: 'Test Venue', description: 'Test Description', start_time: Time.current, end_time: Time.current + 1.hour, google_event_id: '12345', user: current_user, email_guest_list: ['guest1@example.com', 'guest2@example.com']) }  

  subject { dummy_class.new }  

  before do  
    allow(event).to receive(:update)
    subject.initialize_google_client(current_user) 
  end  

  describe '#create_google_event' do  
    it 'calls handle_google_event with POST method' do  
      expect(subject).to receive(:handle_google_event).with(event, 'POST')  
      subject.create_google_event(event)  
    end  
  end  

  describe '#edit_google_event' do  
    it 'calls handle_google_event with PUT method' do  
      expect(subject).to receive(:handle_google_event).with(event, 'PUT')  
      subject.edit_google_event(event)  
    end  
  end  

  describe '#delete_google_event' do  
    it 'makes a DELETE request to the correct endpoint' do  
      expect(subject).to receive(:make_request).with('DELETE', "/calendars/#{Event::CALENDAR_ID}/events/#{event.google_event_id}")  
      subject.delete_google_event(event)  
    end  
  end  

  describe '#get_google_event' do  
    it 'makes a GET request to the correct endpoint and returns the event if ids match' do  
      expected_response = { 'id' => event.google_event_id }  
      allow(subject).to receive(:make_request).with('GET', "/calendars/#{Event::CALENDAR_ID}/events/#{event.google_event_id}").and_return(expected_response)  

      result = subject.get_google_event(event)  
      expect(result).to eq(expected_response)  
    end  

    it 'returns nil if the event id does not match' do  
      expected_response = { 'id' => 'another_id' }  
      allow(subject).to receive(:make_request).with('GET', "/calendars/#{Event::CALENDAR_ID}/events/#{event.google_event_id}").and_return(expected_response)  

      result = subject.get_google_event(event)  
      expect(result).to be_nil  
    end  
  end  

  describe '#handle_google_event' do  
    it 'builds the correct event payload and makes a request' do  
      expect(subject).to receive(:build_event_payload).with(event).and_return({ 'id' => 'new_event_id' })  
      expect(subject).to receive(:make_request).with('POST', "/calendars/#{Event::CALENDAR_ID}/events", anything).and_return({'id' => 'new_event_id'})  

      subject.create_google_event(event)  
      expect(event).to have_received(:update).with(google_event_id: 'new_event_id')  
    end  
  end  

  describe '#build_event_payload' do  
    it 'builds a correct payload for an event' do  
      payload = subject.send(:build_event_payload, event)  
      expect(payload).to include(  
        summary: event.title,  
        location: event.venue,  
        description: event.description,  
        start: have_key(:dateTime),  
        end: have_key(:dateTime),  
        attendees: include(have_key(:email), have_key(:displayName), have_key(:organizer))  
      )  
    end  
  end  

  describe '#format_time' do  
    it 'formats the date correctly' do  
      date = Time.current  
      result = subject.send(:format_time, date)  
      expect(result).to include(dateTime: date.to_datetime.iso8601, timeZone: 'Africa/Nairobi')  
    end  
  end  

  describe '#make_request' do  
    it 'handles Net::HTTPSuccess response' do  
      response = double('Response', body: { 'id' => '123' }.to_json, is_a?: true)  
      allow_any_instance_of(Net::HTTP).to receive(:request).and_return(response)  

      result = subject.send(:make_request, 'GET', '/some/path')  
      expect(result).to eq('id' => '123')  
    end  

    it 'rescues from exceptions and logs errors' do  
      allow_any_instance_of(Net::HTTP).to receive(:request).and_raise(StandardError.new("Network Error"))  
      expect(Rails.logger).to receive(:error).with("Network Error")  
      
      result = subject.send(:make_request, 'GET', '/some/path')  
      expect(result).to be_nil  
    end  
  end  

  describe '#event_attendees' do  
    it 'builds a list of attendees' do  
      event_with_guests = double('Event', email_guest_list: ['guest1@example.com', 'guest2@example.com'], user: current_user)  
      attendees = subject.send(:event_attendees, event_with_guests)  

      expect(attendees.size).to eq(3) # 2 guests + 1 organizer  
    end  
  end  

  describe '#attendee_hash' do  
    it 'creates a hash for an attendee' do  
      result = subject.send(:attendee_hash, 'test@example.com', true)  
      expect(result).to eq(email: 'test@example.com', displayName: 'test', organizer: true)  
    end  
  end  
end