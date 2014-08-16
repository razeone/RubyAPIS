require 'sinatra'
require 'json'
require 'pg'
require 'sinatra/cross_origin'

=begin
This is the ruby file for GIS services
=end

set :bind, '0.0.0.0'

get '/getPoints' do
	cross_origin

	if(params[:latitud] != nil and params[:longitud] != nil)
		lat = params[:latitud].to_f
		lng = params[:longitud].to_f
		$myDistance = Distance.new
		distanceArray = Array.new
		result = JSON.parse(getPoints('RM'))
		result.each do |row|
			distance = $myDistance.getDistance(lat, lng,row["latitud"].to_f, row["longitud"].to_f)
			if(distance < 2)
				row["distance"] = distance
				distanceArray.push(row)
			end
		end
		distanceArray.to_json
	else
		errorHash = {:error => "Se necesita recibir valor de latitud y longitud"}
		errorHash.to_json
	end
end

get '/getStates' do
	cross_origin

	if(params[:estado] == 'all') 
		g = Geometry.new
		g.getStates()
	else
		g = Geometry.new
		g.getGeometry(params[:estado])
	end
end

get '/getStatesByDivision' do
	cross_origin
	g = Geometry.new
	g.getStatesByDivision(params[:division])
end

get '/getDivisions' do
	cross_origin
	g = Geometry.new
	g.getDivisions()
end

get '/getGeoDivisions' do
	cross_origin
	g = Geometry.new
	g.getGeoDivisions()
end

get '/getDistance' do
	
end
	
post '/setFielderLocation' do
	f = Fielder.new
	f.setLocation(params[:id], params[:latitud], params[:longitud]) do |result|
		puts result
	end
end

class Geometry
	def getGeometry(state)
		res = Array.new
		conn = PG.connect(dbname: 'gistmx', user: 'postgres', password: 'Razeone%88', host: '127.0.0.1')
		query = "SELECT admin_name, ST_AsGeoJSON(the_geom) from mexstates WHERE admin_name='"+state+"'"
		conn.exec(query) do |result|
	        for row in result
	        	 res.push(row)
	        end
	        return res.to_json
	    end
    end

    def getStates()
    	res = Array.new
		conn = PG.connect(dbname: 'gistmx', user: 'postgres', password: 'Razeone%88', host: '127.0.0.1')
		query = "SELECT admin_name, ST_AsGeoJSON(the_geom) from mexstates"
		conn.exec(query) do |result|
	        for row in result
	        	 res.push(row)
	        end
	        return res.to_json
	    end
    end

    def getStatesByDivision(division)
    	res = Array.new
    	r = Hash.new
		conn = PG.connect(dbname: 'gistmx', user: 'postgres', password: 'Razeone%88', host: '127.0.0.1')
		query = "SELECT ST_AsGeoJSON(the_geom) as json from mexstates WHERE division='"+division+"'"
		conn.exec(query) do |result|
	        for row in result
	        	 res.push(row)
	        end
	        #r = Hash[*res]
	        return res.to_json
	    end
    end

    def getDivisions()
    	res = Array.new
    	r = Hash.new
		conn = PG.connect(dbname: 'gistmx', user: 'postgres', password: 'Razeone%88', host: '127.0.0.1')
		query = "SELECT DISTINCT division from mexstates"
		conn.exec(query) do |result|
	        for row in result
	        	 res.push(row)
	        end
	        #r = Hash[*res]
	        return res.to_json
	    end
    end

    def getGeoDivisions()
    	res = Array.new
    	r = Hash.new
		conn = PG.connect(dbname: 'gistmx', user: 'postgres', password: 'Razeone%88', host: '127.0.0.1')
		query = "SELECT ST_AsGeoJSON(the_geom) as json, division from mexstates GROUP BY division, the_geom"
		conn.exec(query) do |result|
	        for row in result
	        	 res.push(row)
	        end
	        #r = Hash[*res]
	        return res.to_json
	    end
    end

end

class Distance
	def getDistance(latOrigin, longOrigin, latDestiny, longDestiny)
		radius = 6371
		lat1 = deg2rad(latOrigin)
		lat2 = deg2rad(latDestiny)
		lat = deg2rad(latDestiny-latOrigin)
		long = deg2rad(longDestiny-longOrigin)

		a = Math.sin(lat/2) * Math.sin(lat/2) + Math.cos(lat1) * Math.cos(lat2) * Math.sin(long/2) * Math.sin(long/2)
		c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
		return radius * c
	end

	def deg2rad(deg)
		return (deg * Math::PI / 180.0)
	end
end

class Fielder
	def setLocation(id,lat,lng)
		conn = PG.connect(dbname: 'gistmx', user: 'postgres', password: 'Razeone%88', host: '127.0.0.1')
		query = "INSERT INTO fielders (fielderid, latitud, longitud) VALUES("+id+","+lat+","+lng+")"
		#puts query
		result = conn.exec(query)
		return result;
	end
end

def getPoints(division)
	res = Array.new
	conn = PG.connect(dbname: 'gistmx', user: 'postgres', password: 'Razeone%88', host: '127.0.0.1')
	query = "SELECT nombre, direccion, telefono, division, area, division, nps, paquete, latitud, longitud from clientes WHERE latitud IS NOT NULL AND telefono LIKE '55%'"
	conn.exec(query) do |result|
        for row in result
        	 res.push(row)
        end
    end
    return res.to_json
end