class ApplicationMailer < ActionMailer::Base
  default from: "ResiTown #{CITY_NAME} <norton.allene@gmail.com>"
  layout 'mailer'
end
