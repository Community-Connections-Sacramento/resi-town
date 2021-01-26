class UserMailer < ApplicationMailer
    def office_hour_invite
      office_hour = OfficeHour.where.not(participant_id: nil).last
  
      UserMailer.with(office_hour: office_hour).office_hour_invite
    end
  
    def office_hour_application
      office_hour = OfficeHour.where.not(application_user_ids: nil).last
  
      UserMailer.with(office_hour: office_hour, application: office_hour.applications[0]).office_hour_application
    end

    def welcome_email
      @user = params[:user]
      # @url  = 'https://resitown.com/users/sign_in'
      mail(to: "<#{@user.email}>", subject: "[ResiTown Sacramento: Sign Up Confirmed] Thank you for joining the ResiTown community!")
    end
  
  end