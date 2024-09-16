require 'rails_helper'

RSpec.describe EventsController, type: :controller do
    let(:user) { FactoryBot.create(:user) }

    before do
        @event = FactoryBot.create(:event, user: user)
        sign_in user 
    end
    describe 'POST #sync_event_with_google' do
    it 'syncs the event with Google and updates the guest list' do
      attendees = [double(email: 'guest1@example.com'), double(email: 'guest2@example.com')]
      google_event = double(attendees: attendees)

      allow(Event).to receive(:find).with(@event.id.to_s).and_return(@event)
      allow(@event).to receive(:get_google_event).with(@event).and_return(google_event)

      post :sync_event_with_google, params: { id: @event.id }

      expect(@event.guest_list).to eq('guest1@example.com, guest2@example.com') 
      expect(response).to redirect_to(event_path(@event)) 
      expect(flash[:notice]).to eq("Event has been synced with google successfully.") 
    end
  end
end