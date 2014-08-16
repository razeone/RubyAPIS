class Cliente
	def getClientByPhone(phoneNumber)
		
		conn.exec(query) do |result|
	        for row in result
	        	 res.push(row)
	        end
	    end
	    return res.to_json
	end

	def setLatLng(lat, lng)
		
end
