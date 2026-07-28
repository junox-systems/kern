class ProfilesController < ApplicationController
  def show
    @operator = Current.operator
  end

  def update
    @operator = Current.operator
    if @operator.update(profile_params)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    permitted = params.require(:operator).permit(:name, :email_address, :timezone, :password, :password_confirmation)
    if permitted[:password].blank? && permitted[:password_confirmation].blank?
      permitted.except(:password, :password_confirmation)
    else
      permitted
    end
  end
end
