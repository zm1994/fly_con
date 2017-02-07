require 'json'
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def get_airports_from_flight_conection
    arr_code_from_file = []
    File.open(Rails.root + "airports.txt", "r") do |infile|
      # push airport code
      while (line = infile.gets)
        words_in_line = line.split(',')
        code = words_in_line[4].to_s.downcase.gsub('"', '')
        arr_code.push(code) if code != '\n' && !code.empty?
      end
    end

    array_airports = []
    arr_code_from_file.each do |code|
      response = Faraday.get "http://www.flightconnections.com/autocompl_airport.php?term=#{code}"
      puts JSON.parse(response.body)
      puts JSON.parse(response.body).empty?
      unless JSON.parse(response.body).empty?
        parsed_response = JSON.parse(response.body)[0]
        item = Airport.new
        item[:code_airport] = code
        item[:id_airport] = parsed_response['id']
        array_airports.push(item)
      end
      sleep 0.3
    end
    array_airports.each(&:save)
  end

  def get_available_directions
    airport = Airport.first
    puts "http://www.flightconnections.com/ro#{airport[:id_airport]}.json?v=667&f=no0"
    response = Faraday.get "http://www.flightconnections.com/ro#{airport[:id_airport]}.json?v=667&f=no0"
    puts JSON.parse(response.body)
    parsed_response = JSON.parse(response.body)

    # array_available_direct = []
    iterator = 0
    # parsed_response['pts'].each do |code_airport|
    #   if(code_airport != parsed_response['pts'].first)
    #     direction = AvailableDirection.new
    #     direction[:departure_code] = parsed_response['pts'].first
    #     direction[:arrival_code] = code_airport
    #     array_available_direct.push(direction)
    #   end
    #
    # end

    loc = Location.new(parsed_response['crd'][iterator], parsed_response['crd'][iterator + 1])
    res = Airport.where(code_airport: airport[:code_airport]).set(location: loc)
    puts res
    # puts res[:location]
    # # res.update
    # iterator = iterator + 2

    # array_available_direct.each(&:save)


    # client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'flight_connection')
    # collection = client[:ids_airports]
    # airp = collection.find({})
    # array = []
    # airp.each do |airport|
    #   item = Airport.new
    #   item[:code_airport] = airport[:code_airport]
    #   item[:id_airport] = airport[:id_airport]
    #   array.push(item)
    # end
    #
    # array.each(&:save)

    # puts collection.find({id_airport: 2952})
    # puts collection.find({id_airport: 4832})
    #
    # airp = Airport.new
    # airp[:code] = 'test1'
    # airp[:id_airport] = 223
    # airp[:location] = Location.new
    # airp[:location][:lat] = 9.323434
    # airp[:location][:lon] = 10.323434
    #
    # airp1 = Airport.new
    # airp1[:code] = 'test1'
    # airp1[:id_airport] = 443
    # airp1[:location] = Location.new
    # airp1[:location][:lat] = 90.323434
    # airp1[:location][:lon] = 109.323434
    #
    # airp.save!
    # airp1.save!
    #
    #
    # direction = Direction.new
    # direction[:departure] = airp
    # direction[:arrival] = airp1
    # direction[:transfers] = []
    # direction[:transfers].push(airp1)
    # direction[:transfers].push(airp1)
    #
    # direction.save!
    # res = Direction.find_by(:'departure.id_airport' => 223)
    # puts res
  end
end
