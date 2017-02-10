class AvailableDirection
  include Mongoid::Document
  store_in collection: "available_directions", database: "flight_connection"
  field :departure_id, type: Integer
  field :arrival_id, type: Integer

end
