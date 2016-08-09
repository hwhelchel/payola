module Payola
  class CustomersController < ApplicationController

    before_filter :check_modify_permissions, only: [:update]

    def update
      if params[:id].present?
        Payola::UpdateCustomer.call(params[:id], customer_params)
        redirect_to return_to, notice: t('payola.customers.updated')
      else
        redirect_to return_to, alert: t('payola.customers.not_updated')
      end
    end

    private

    # Only including default_source for now, though other attributes can be used
    # (https://stripe.com/docs/api#update_customer)
    def customer_params
      params.require(:customer).permit(:default_source)
    end

    def check_modify_permissions
      if self.respond_to?(:payola_can_modify_customer?)
        redirect_to(
          return_to,
          alert: t('payola.customers.not_authorized')
        ) and return unless self.payola_can_modify_customer?(params[:id])
      else
        raise NotImplementedError.new("Please implement ApplicationController#payola_can_modify_customer?")
      end
    end

    def return_to
      params[:return_to] || :back
    end

  end
end
