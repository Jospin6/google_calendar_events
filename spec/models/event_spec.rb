require 'rails_helper'  

RSpec.describe Event, type: :model do  
  describe "validations" do  
    it 'is valid with valid attributes' do  
      expect(FactoryBot.build(:event)).to be_valid  
    end  

    it 'is not valid without a title' do  
      expect(FactoryBot.build(:event, title: nil)).not_to be_valid   
    end  
 
    it 'is not valid without a venue' do  
      expect(FactoryBot.build(:event, venue: nil)).not_to be_valid   
    end  

    it 'is not valid with the end_time before start_time' do  
      event = FactoryBot.build(:event, start_time: Time.current + 1.day, end_time: Time.current)  
      expect(event).not_to be_valid  
    end  
  end  
end 