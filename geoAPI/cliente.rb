class Cliente
	def getClientByPhone(phoneNumber)
		conn = PG.connect(dbname: 'gistmx', user: 'postgres', password: '', host: '127.0.0.1')
		query = "SELECT * from clientes WHERE telefono='" + phoneNumber + "'"
		conn.exec(query) do |result|
	        for row in result
	        	 res.push(row)
	        end
	    end
	    return res.to_json
	end

	def setLatLng(lat, lng)
		
end
