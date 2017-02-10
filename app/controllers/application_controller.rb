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
    array_available_direct = []
    Airport.all.each do |airport|
      iter_coordinates = 0
      puts "http://www.flightconnections.com/ro#{airport[:id_airport]}.json?v=667&f=no0"
      # send request to fly connection for get available direction by id_airport in their system
      response = Faraday.get "http://www.flightconnections.com/ro#{airport[:id_airport]}.json?v=667&f=no0"
      puts JSON.parse(response.body)
      parsed_response = JSON.parse(response.body)
      parsed_response['pts'].each do |id_airport|    # parse all points as code airports
          if(id_airport != parsed_response['pts'].first) #first point is departure
            direction = AvailableDirection.new
            direction[:departure_id] = parsed_response['pts'].first  # set first point as departure
            direction[:arrival_id] = id_airport # set code_airport point as arrival
            array_available_direct.push(direction)
          end
          # update location airport from response ['crd'], count ['crd'] array more on twice then ['pts']
          # first 2 coordinates is departure (item[:id_airport]), another - available directions
          loc = Location.new(parsed_response['crd'][iter_coordinates], parsed_response['crd'][iter_coordinates + 1] )
          Airport.where(id_airport: id_airport).set(location: loc)
          iter_coordinates = iter_coordinates + 2
      end
      sleep 0.3
    end
    array_available_direct.each(&:save)
  end

  def get_directions_without_transfers
    arr_direct_routes = []
    AvailableDirection.all.each do |available_direction|
      response = Faraday.get "http://www.flightconnections.com/ro#{available_direction[:departure_id]}_#{available_direction[:arrival_id]}.json?v=667&f=no0"
      puts "http://www.flightconnections.com/ro#{available_direction[:departure_id]}_#{available_direction[:arrival_id]}.json?v=667&f=no0"
      parsed_response = JSON.parse(response.body) rescue {}
      unless parsed_response['data'].nil? || parsed_response['data'].empty?
        direction_with_trans = DirectionWithTransfer.new
        direction_with_trans[:departure_id_airport] = available_direction[:departure_id]
        direction_with_trans[:arrival_id_airport] = available_direction[:arrival_id]
        arr_direct_routes.push(direction_with_trans)
      end
      sleep 0.1
    end
    arr_direct_routes.each(&:save)
  end

  def get_directions_with_transfers(count_transfers)
    arr_direct_routes = []
    AvailableDirection.all.each do |available_direction|
      response = Faraday.get "http://www.flightconnections.com/ro#{available_direction[:departure_id]}_#{available_direction[:arrival_id]}_#{count_transfers + 1}_0_0.json?v=667&f=no0"
      parsed_res = JSON.parse(response.body) rescue []
      puts "http://www.flightconnections.com/ro#{available_direction[:departure_id]}_#{available_direction[:arrival_id]}_#{count_transfers + 1}_0_0.json?v=667&f=no0"
      puts parsed_res
      unless parsed_res.nil? || parsed_res.empty?
        parsed_res['routedata'].each do |route|   #array multidimensional routes
          direction = []
          route.each do |transfer|  #sub multidimensional array in route item, it contains transfers
            direction.push(transfer[0])  #push in direction id airport, transfer[0] - departure
            direction.push(transfer[1])  #push in direction id airport, transfer[1] - arrival
          end
          direction = direction.uniq    #set uniq items in direction
          #create document DirectionWithTransfer
          direction_with_trans = DirectionWithTransfer.new
          direction_with_trans[:departure_id_airport] = direction[0]
          direction_with_trans[:arrival_id_airport] = direction[-1]
          direction_with_trans[:transfers_id] = direction[1...-1] unless direction[1...-1].nil?
          arr_direct_routes.push(direction_with_trans)
        end
      end
    end
    arr_direct_routes.each(&:save)
  end
end
