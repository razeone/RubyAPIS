class dbPG
	def getConnect
		conn = PG.connect(dbname: 'gistmx', user: 'postgres', password: '', host: '127.0.0.1')
