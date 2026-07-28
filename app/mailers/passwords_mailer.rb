class PasswordsMailer < ApplicationMailer
  def reset(operator)
    @operator = operator
    mail subject: "Reset your password", to: operator.email_address
  end
end
