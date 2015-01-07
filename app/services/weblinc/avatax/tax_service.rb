module Weblinc
  module Avatax
    class TaxService
      attr_reader :avatax_tax_service, :settings

      # AvaTax::TaxService doesn't provide a good way to change settings thru initialize
      def initialize(settings=Weblinc::Avatax::Setting.current)
        @settings = settings
        AvaTax.configure do 
          account_number settings.account_number
          license_key    settings.license_key
          service_url    settings.service_url
        end
        @avatax_tax_service = AvaTax::TaxService.new
      end

      def get(request_hash)
        @avatax_tax_service.get(request_hash)
      end

      def cancel(request_hash)
        @avatax_tax_service.cancel(request_hash)
      end

      def estimate(coordinates, sale_amount)
        @avatax_tax_service.estimate(coordinates, sale_amount)
      end

      def ping
        @avatax_tax_service.ping
      end
    end
  end
end
