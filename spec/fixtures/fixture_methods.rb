module Weblinc
  module Avatax
    module FixtureMethods
      def create_checkout_order(overrides={})
        attributes = {
          number: Faker::Number.number(5)
        }.merge(overrides)

        shipping_state = Faker::Address.state_abbr

        if Country['US'].blank?
          create_country(name: 'US', alpha_2_code: 'US', alpha_3_code: 'USA')
        end

        if Region["US-#{shipping_state}"].blank?
          create_region(country: Country['US'], name: shipping_state, abbreviation: shipping_state)
        end

        shipping_method = create_shipping_method
        sku = Faker::Lorem.characters(6).upcase
        product = create_product(variants: [{ sku: sku, regular: 5.to_m, tax_code: 'P0000000' }])

        Weblinc::Order.new(attributes).tap do |order|
          order.set_shipping_method(
            id: shipping_method.id,
            name: shipping_method.name,
            base_price: shipping_method.rates.first.price,
            tax_code: shipping_method.tax_code
          )
          order.items.build(product_id: product.id, sku: sku, quantity: 2)

          order.set_shipping_address(
            first_name:  Faker::Name.first_name,
            last_name:   Faker::Name.last_name,
            street:      Faker::Address.street_address,
            street_2:    Faker::Address.secondary_address,
            city:        Faker::Address.city,
            region:      shipping_state,
            postal_code: Faker::Address.zip,
            country:     'US'
          )

          Weblinc::Pricing.perform(order)

          order.save!
        end
      end
    end
  end
end
