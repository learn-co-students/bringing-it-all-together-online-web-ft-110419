require 'pry'
class Dog 
attr_accessor :name, :breed, :id

    def initialize(attrib)
        attrib.each {|key, value| self.send(("#{key}="), value)}
    end

    def self.create_table 
        sql = <<-SQL 
            CREATE TABLE dogs 
            (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
            SQL

            DB[:conn].execute(sql)
    end 

    def self.drop_table 
        DB[:conn].execute('DROP TABLE dogs;')
    end 

    def save 
        if self.id 
            update
        else 
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, name, breed)
        @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
        end 
        self 
    end 

    def self.create(name_breed) 
        new_dog = self.new(name_breed)
        new_dog.save 
        new_dog
    end 

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?
            WHERE id = ?
            SQL
        DB[:conn].execute(sql, name, id)
    end 

    def self.new_from_db(inst) 
      hash = {:id => inst[0], :name => inst[1], :breed => inst[2]}
      new_dog = self.new(hash)
      new_dog
    end 

    def self.find_by_id(id) 
        sql = <<-SQL 
            SELECT *
            FROM dogs
            WHERE id = ?
            SQL
        dog_attr = DB[:conn].execute(sql, id).map {|row| self.new_from_db(row)}.first
    end 

    def self.find_or_create_by(dog)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
        dog_data = DB[:conn].execute(sql, dog[:name], dog[:breed])
          if !dog_data.empty?
            dog_exist = {id: dog_data[0][0], name: dog_data[0][1], breed: dog_data[0][2]}
            dog_data = self.new(dog_exist)
          else
            dog_data = self.create(dog)
            find_by_id(dog_data.id)
          end 
          dog_data
    end 

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        DB[:conn].execute(sql, name).map {|row| self.new_from_db(row)}.first
    end 

end 