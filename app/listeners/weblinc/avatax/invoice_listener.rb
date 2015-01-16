module Weblinc
  module Avatax
    class InvoiceListener
      def weblinc_order_placed(order)
        Weblinc::Avatax::TaxWorker.perform_async(order.number)
      end

      def weblinc_fulfillment_status_updated(number, status, payload)
        fulfillment = Weblinc::Fulfillment::Order.find_by(number: number)
        order = Weblinc::Order.find_by(number: number)
        tax_service = Weblinc::Avatax::TaxService.new(order)

        if fulfillment.status == :cancelled
          tax_service.cancel
        else
          # if we're not cancelling, deal with any cancellations
          tax_service.credit(payload[:cancellations])
        end

        if fulfillment.status == :shipped
          tax_service.commit
        end
      end
    end
  end
end
