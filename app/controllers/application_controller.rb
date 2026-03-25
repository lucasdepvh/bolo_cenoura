class ApplicationController < ActionController::Base
    before_action :authenticate_admin!, except: :product_image_show
    include Pagy::Backend

    def after_sign_in_path_for(resource)
        return admin_root_path if resource.is_a?(Admin)

        super
    end

    def after_sign_out_path_for(resource_or_scope)
        return new_admin_session_path if resource_or_scope == :admin

        super
    end

    def product_image_show
        @product_image = ProductImage.find(params[:id])
        send_data @product_image.data, type: @product_image.filetype, disposition: 'inline'
    end
end
