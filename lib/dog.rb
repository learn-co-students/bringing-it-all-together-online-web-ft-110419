class Dog

    attr_accessor :name, :breed, :id


    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql) 
    end
    
    def save
        if self.id
            self.update
        else
            sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end
    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
    end
    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        self.new(id: id, name: name, breed:breed)
    end
    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
        DB[:conn].execute(sql,name).map {|row| self.new_from_db(row)}.first
    end
    def self.find_by_id(num)
        sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
        DB[:conn].execute(sql,num).map {|row|self.new_from_db(row)}.first
    end
    def self.find_or_create_by(name:,breed:)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1"
        dog = DB[:conn].execute(sql,name,breed)
        if !dog.empty?
            self.new_from_db(dog[0])
        else
            self.create(name: name, breed: breed)
        end
    end
    def update
        sql = "UPDATE dogs SET name = ?, breed = ?  WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end