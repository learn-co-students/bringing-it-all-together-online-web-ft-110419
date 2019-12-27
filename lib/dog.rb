require 'pry'
class Dog

    attr_accessor :name, :breed, :id

    def initialize(attributes)
        attributes.each{|key, value| self.send(("#{key}="), value)}
        @id ||= nil
    end

    def self.all
        sql = <<-SQL
        SELECT *
        FROM dogs
        SQL
        DB[:conn].execute(sql).map{|row| self.new_from_db(row)}
    end

    def self.create_table
        sql = <<-SQL 
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT)
            SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    def self.create(attributes)
        dog = self.new(attributes)
        dog.save
        dog
    end

    def self.new_from_db(row)
        dog = Dog.new(id: row[0], name: row[1], breed: row[2])
        dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        LIMIT 1
        SQL
        DB[:conn].execute(sql, id).map{|row| self.new_from_db(row)}.first
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            data = dog[0]
            dog = Dog.new_from_db(data)
        else
            dog = self.create(name: name, breed: breed)
        end
    end
    

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        LIMIT 1
        SQL
        DB[:conn].execute(sql, name).map{|row| self.new_from_db(row)}.first
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs(name, breed) 
        VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end