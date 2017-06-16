require "avatax"
require "hashie"
require "workarea/core"
require "workarea/storefront"
require "workarea/admin"

module Workarea
  module Avatax
    include ActiveSupport::Configurable

    # Config for how orders should post to avatax
    # :none - no action happens
    # :post - a salesInvoice transaction is created
    # :commit - a commited salesInvoice is created
    config.order_handling = :none

    def self.commit?
      config.order_handling == :commit
    end

    def self.gateway=(gateway)
      Workarea.config.gateways.avatax = gateway
    end

    def self.gateway
      Workarea.config.gateways.avatax
    end

    def self.auto_configure_gateway
      if Rails.application.secrets.avatax.present?
        self.gateway = ::AvaTax.client
      elsif gateway.blank?
        self.gateway = Avatax::BogusGateway.new
      end
    end
  end
end

require "workarea/avatax/engine"
require "workarea/avatax/version"
require "workarea/avatax/tax_request"
require "workarea/avatax/tax_request/line_item"
require "workarea/avatax/tax_request/order_line_item"
require "workarea/avatax/tax_request/shipping_line_item"
require "workarea/avatax/tax_request/addresses"
require "workarea/avatax/tax_request/response"
require "workarea/avatax/bogus_gateway"
require "workarea/avatax/bogus_gateway/bogus_create_transaction"