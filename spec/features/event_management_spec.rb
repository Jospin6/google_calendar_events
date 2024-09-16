require 'rails_helper'  

RSpec.feature "Event management", type: :feature do
    scenario "Create an event" do
        visit new_event_path

        fill_in "title",	with: "event title"
        fill_in "description",	with: "the event description"
        fill_in "venue",	with: "123 street kigali"
        fill_in "start_time",	with: Time.now + 15.days
        fill_in "end_time",	with: Time.now + 15.days + 1.hour

        click_button 'Create Event'

        expect(page).to have_content("Event was successfully created")

    end
end