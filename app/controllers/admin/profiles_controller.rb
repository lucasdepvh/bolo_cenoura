class Admin::ProfilesController < ApplicationController
  layout "admin"

  def edit
    @admin = current_admin
  end

  def update
    @admin = current_admin
    params_hash = profile_params.to_h

    should_update_password = params_hash["password"].present? || params_hash["password_confirmation"].present?

    updated =
      if should_update_password
        @admin.update_with_password(params_hash)
      else
        @admin.update_without_password(params_hash.except("current_password", "password", "password_confirmation"))
      end

    if updated
      bypass_sign_in(@admin)
      redirect_to edit_admin_profile_path, notice: "Perfil atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:admin).permit(:email, :current_password, :password, :password_confirmation)
  end
end
