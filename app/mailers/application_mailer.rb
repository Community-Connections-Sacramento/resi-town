class ApplicationMailer < ActionMailer::Base
  default from: "#{CITY_NAME} Help With Covid <norton.allene@gmail.com>"
  layout 'mailer'
end
