class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
    @operator = Operator.new
  end

  def create
    @operator = Operator.new(registration_params)
    if @operator.save
      start_new_session_for @operator
      redirect_to after_authentication_url, notice: "Account successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:operator).permit(:email_address, :password, :password_confirmation, :name)
  end
end
