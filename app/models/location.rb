class Location
  # include Mongoid::Document
  # field :lat, type: Float
  # field :lon, type: Float
  # embedded_in :airport
  #
  attr_reader :latitude, :longitude

  def initialize(lan, lon)
    @latitude = lan
    @longitude= lon
  end

  # Converts an object of this instance into a database friendly value.
  def mongoize
    [ latitude, longitude ]
  end

  class << self

    # Get the object as it was stored in the database, and instantiate
    # this custom class from it.
    def demongoize(object)
      Point.new(object[0], object[1])
    end

    # Takes any possible object and converts it to how it would be
    # stored in the database.
    def mongoize(object)
      case object
        when Location then object.mongoize
        when Hash then Location.new(object[:x], object[:y]).mongoize
        else object
      end
    end

    # Converts the object that was supplied to a criteria and converts it
    # into a database friendly form.
    def evolve(object)
      case object
        when Location then object.mongoize
        else object
      end
    end
  end
end
