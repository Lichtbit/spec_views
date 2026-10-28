# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  def signup
    mail(to: 'to@example.com', subject: 'Welcome')
  end
end
