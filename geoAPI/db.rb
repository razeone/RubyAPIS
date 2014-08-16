class dbPG
	def getConnect
		conn = PG.connect(dbname: 'gistmx', user: 'postgres', password: 'Razeone%88', host: '127.0.0.1')