class Airport
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  store_in collection: "airports", database: "flight_connection"
  field :code_airport, type: String
  field :id_airport, type: Integer
  field :location, type: Location
end
