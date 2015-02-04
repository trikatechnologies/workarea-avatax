module Weblinc
  module Avatax
    class TaxRequest
      attr_accessor :order, :user
      attr_writer :commit, :doc_type

      DEFAULT_DEST_CODE = "DEST"
      DEFAULT_ORIGIN_CODE = "ORIGIN"

      def initialize(options = {})
        @order = options[:order]
        @commit = options[:commit]
        @doc_type = options[:doc_type]
        @user = options[:user]
      end

      # PurchaseOrder type means that the document will not be saved
      # PurchaseInvoice type means that the document will be saved and 
      # appear in the Avatax admin
      def doc_type
        if settings.doc_handling == :none || @doc_type.nil?
          "SalesOrder"
        else
          @doc_type
        end
      end

      def commit
        if settings.doc_handling == :none || @commit.nil?
          false
        else
          @commit
        end
      end

      # if we're not comitting don't bother with a real customer code since
      # the document is temporary anyway (via DocType). Must be < 50 chars
      def customer_code
        if doc_type == "SalesInvoice"
          order.email.truncate(50, omission: '')
        else
          "TEMPORARY"
        end
      end

      def doc_code
        "ORDER-#{order.number}"
      end

      def distribution_address
        dist_center = { AddressCode: DEFAULT_ORIGIN_CODE }
        dist_center.merge(Weblinc::Avatax.config.dist_center)
      end

      def shipping_address
        {
          AddressCode: DEFAULT_DEST_CODE,
          Line1: order.shipping_address.street,
          Line2: order.shipping_address.street_2,
          City: order.shipping_address.city,
          Region: order.shipping_address.region,
          Country: order.shipping_address.country,
          PostalCode: order.shipping_address.postal_code
        }
      end

      def item_lines
        order.items.flat_map.with_index do |item, i|
          adjustments = item.price_adjustments.select do |a|
            !a.discount? && a.price == 'item'
          end
          tax_codes = adjustments.map { |a| a.data['tax_code'] }

          tax_codes.uniq.map do |code|
            Weblinc::Avatax::Line.new(item: item, tax_code: code).as_json
          end
        end
      end

      def shipping_line
        shipping_total = order.shipping_method.price_adjustments.sum

        {
          LineNo: "SHIPPING",
          ItemCode: "SHIPPING",
          Description: @order.shipping_method.name,
          Qty: 1,
          Amount: shipping_total.to_s,
          TaxCode: 'FR',
          OriginCode: DEFAULT_ORIGIN_CODE,
          DestinationCode: DEFAULT_DEST_CODE
        }
      end

      def lines
        item_lines.push(shipping_line)
      end

      def exemption_no
        user.try(:exemption_no)
      end

      def usage_type
        user.try(:customer_usage_type)
      end

      def as_json
        hash = {
          CustomerCode: customer_code,
          DocType: doc_type,
          Commit:  commit,
          DocDate: Time.now.strftime("%Y-%m-%d"),
          CompanyCode:  settings.company_code,
          Client:  "WEBLINC AVATAX CONNECTOR #{Weblinc::Avatax::VERSION}",
          DocCode:  doc_code,
          DetailLevel:  "Tax",
          Addresses:  [ distribution_address, shipping_address ],
          Lines:  lines
        }

        if exemption_no.present?
          hash[:ExemptionNo] = exemption_no
        end

        if usage_type.present?
          hash[:CustomerUsageType] = usage_type
        end

        hash
      end

      private

      def settings
        @settings ||= Weblinc::Avatax::Setting.current
      end
      

    end
  end
end
