class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
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
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?)
            SQL
            
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
      self
    end

    def self.create(hash)
        new_dog = Dog.new(name: hash[:name], breed: hash[:breed])
        new_dog.save
        new_dog
    end

    def self.new_from_db(row)
        new_dog = self.new(id: row[0], name: row[1], breed: row[2]) 
    end

    def self.find_by_id(ident)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, ident).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        finder = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !finder.empty?
            finder_data = finder[0]
            finder = Dog.new_from_db(finder_data)
        else
            finder = self.create(name: name, breed: breed)
        end
        finder
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
        SQL

        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

            



end