class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, 
          :registerable,
          :recoverable, 
          :rememberable, 
          :validatable, 
          :trackable, 
          :omniauthable, 
          omniauth_providers:  %i[ google_oauth2 ]

  def self.from_omniauth(auth)
    user = User.where(google_id: auth.try(:uid) || auth["uid"]).first
    if user
      return user
    else
      registered_user = User.where(google_id: auth.try(:uid) || auth["uid"]).first || User.where(email: auth.try(:info).try(:email) || auth["info"]["email"]).first
      if registered_user
        unless registered_user.google_id == (auth.try(:uid) || auth["uid"])
          registered_user.update_attributes(google_id: auth.try(:uid) || auth["uid"])
        end
        return registered_user
      else
        user = User.new(:google_id => auth.try(:uid) || auth["uid"])
        user.email = auth.try(:info).try(:email) || auth["info"]["email"]
        user.password = Devise.friendly_token[0,20]
        user.save
        puts user
      end
      user
    end
  end

end
