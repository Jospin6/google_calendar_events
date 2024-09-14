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

end
