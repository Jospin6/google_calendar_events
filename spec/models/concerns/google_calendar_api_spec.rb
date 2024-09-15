require 'rails_helper'

RSpec.describe GoogleCalendarApi do
    let(:dummy_class) { Class.new { include GoogleCalendarApi } } 
    let(:instance) { dummy_class.new }

    describe "#initialize_google_client" do
        it 'return the current user access_token' do
            
        end
    end
    
    
  
end