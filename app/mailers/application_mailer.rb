class ApplicationMailer < ActionMailer::Base
  default from: "ResiTown #{CITY_NAME} <info@sacconect.com>"
  layout 'mailer'
end
