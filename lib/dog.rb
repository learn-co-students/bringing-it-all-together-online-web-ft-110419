require "pry"
class Dog 

    attr_accessor :id, :name, :breed


    def initialize(id: nil, name:, breed:)
        @id = id 
        @name = name
        @breed = breed
    end 


    def self.create_table 
      sql = <<-SQL
      Create table if not exists dogs (
          id Integer primary key ,
          name text,
          breed text
      )
      SQL
      DB[:conn].execute(sql)
    end 


    def self.drop_table 
        sql = <<-SQL
        Drop table dogs 
        SQL
        DB[:conn].execute(sql)
    end 


    def save 
        sql = <<-SQL 
        Insert into dogs (name, breed) values (?, ?)
        SQL
        DB[:conn].execute(sql, name, breed)
        @id = DB[:conn].execute("select last_insert_rowid() from dogs")[0][0]
        self 
    end 


    def self.create(hash_of_attributes)
        dog = self.new(hash_of_attributes)
        dog.save 
        dog
    end 


    def self.new_from_db(row)
    hash_of_row = {
       :id => row[0],
       :name => row[1],
       :breed => row[2]
    }
    self.new(hash_of_row)
    end 


    def self.find_by_id(id)
        sql = <<-SQL 
        select * from dogs where id = ?
        SQL
        DB[:conn].execute(sql, id).map {|row| self.new_from_db(row)}.first
    end 

   
  
    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        select * 
        from dogs 
        where name = ? and breed = ?
        SQL
        dog = DB[:conn].execute(sql, name, breed).first
        if dog 
            new_dog = self.new_from_db(dog)
        else 
            new_dog = self.create({name: name, breed: breed})
        end 
        new_dog
    end 


    def self.find_by_name(name)
        sql = <<-SQL 
        select *
        from dogs 
        where name = ?
        SQL
        DB[:conn].execute(sql, name).map {|row| self.new_from_db(row)}.first
    end 

    def update 
        sql = <<-SQL
        Update dogs set name = ?, breed = ? where id = ?
        SQL
        DB[:conn].execute(sql,self.name, self.breed, self.id)
    end 

    


end 