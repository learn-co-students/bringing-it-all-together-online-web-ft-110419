class Dog
	attr_accessor :id, :name, :breed
	def initialize(dog_hash)
		dog_hash.each do |attr, value|
			self.send("#{attr}=", value)
		end 
	end 

	def self.create_table
		sql_create = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);"
		DB[:conn].execute(sql_create)
	end

	def self.drop_table
		sql_delete = "DROP TABLE IF EXISTS dogs"
		DB[:conn].execute(sql_delete)
	end 

	def self.new_from_db(row)
		Dog.new({:id => row[0], :name => row[1], :breed => row[2]})
	end 

	def self.create(dog_hash)
		new_dog = Dog.new(dog_hash)
		new_dog.save
	end

	def self.find_by_name(name)
		sql_find = "SELECT * FROM dogs WHERE name = ?"
		found = DB[:conn].execute(sql_find, name)
		if found.length == 2
			return [self.new_from_db(found[0]), self.new_from_db(found[1])]
		else 
			found_dog = self.new_from_db(found.flatten)
		end
	end

	def self.find_by_id(id)
		sql_find = "SELECT * FROM Dogs WHERE id = ?"
		found = DB[:conn].execute(sql_find, id).flatten
		self.new_from_db(found)
	end

	def self.find_or_create_by(hash)
		found = self.find_by_name(hash[:name])
		if found && found.class != Array && found.breed == hash[:breed]
			return self.find_by_name(hash[:name])
		elsif self.find_by_name(hash[:name]).class == Array
			dogs = self.find_by_name(hash[:name])
			dogs.each do |dog|
				if dog.name == hash[:name] && dog.breed == hash[:breed]
					return dog
				else 
					return Dog.create(hash)
				end
			end 
		else
			new_dog = Dog.create(hash)
			puts "Creating a new dog"
			return new_dog
		end 
	end 


	def update
		sql_update = "UPDATE Dogs SET name = ?, breed = ? WHERE id = ?;"
		DB[:conn].execute(sql_update, self.name, self.breed, self.id)
	end

	def save
		if !@id
			sql_insert = "INSERT INTO Dogs (name, breed) VALUES (?,?)"
			DB[:conn].execute(sql_insert, self.name, self.breed)
			sql_id = "SELECT last_insert_rowid() FROM Dogs"
			@id = DB[:conn].execute(sql_id).flatten[0]
		else
			self.update
		end
		self
	end
end