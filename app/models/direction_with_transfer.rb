class DirectionWithTransfer
  include Mongoid::Document
  store_in collection: "directions_with_transfers", database: "flight_connection"
  field :departure_id_airport, type: Integer
  field :transfers_id, type: Array
  field :arrival_id_airport, type: Integer
  index ({departure_id: 1, arrival_id: 1})
end
