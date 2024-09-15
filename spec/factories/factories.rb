FactoryBot.define do
  factory :user do  
    email { "user@example.com" }   
    password { "password123" } 
    google_id { SecureRandom.uuid }  
  end 

  factory :event do
    title {"the event title"}
    start_time { Time.now + 15.days }
    end_time { start_time + 1.hour }
    venue { "123 street kigali"}
    description { "the event description" }
    association :user
  end
end