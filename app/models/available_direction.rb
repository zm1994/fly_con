class AvailableDirection
  include Mongoid::Document
  store_in collection: "available_directions", database: "flight_connection"
  field :departure_code, type: Integer
  field :arrival_code, type: Integer
end
