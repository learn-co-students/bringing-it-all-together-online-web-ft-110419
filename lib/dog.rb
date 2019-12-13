class Dog

    attr_accessor :id, :name, :breed

    def initialize(id: nil,name: , breed: )
        @id = id
        @name = name
        @breed = breed
    end
    
    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
        self
    end

    def self.create(dog_hash)
        dog = self.new(name: nil, breed: nil)
        dog_hash.each{|key, val| dog.send("#{key}=", val)}
        dog.save
        dog
    end

    def self.new_from_db(row)
        id, name, breed = row[0], row[1], row[2]
        dog = self.new(name: nil, breed: nil)
        dog.id = id
        dog.name = name
        dog.breed = breed
        dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
        SQL
        row = DB[:conn].execute(sql, id).flatten
        self.new_from_db(row)
    end

    def self.find_or_create_by(name:, breed: )
        sql = <<-SQL
            SELECT * FROM dogs WHERE
            name = ? and breed = ?
        SQL
        data = DB[:conn].execute(sql, name, breed).flatten
        if !data.empty?
            dog = self.find_by_id(data[0])
        else
            dog = self.create({name: data[0], breed: data[1]})
        end
        dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
        SQL
        data = DB[:conn].execute(sql, name).flatten
        self.new_from_db(data)
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id  = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end