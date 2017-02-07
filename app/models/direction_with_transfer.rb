class DirectionWithTransfer
  include Mongoid::Document
  store_in collection: "directions_with_transfers", database: "flight_connection"
  field :departure_code, type: Integer
  field :transfers, type: Array
  field :arrival_code, class_name: Integer
end
