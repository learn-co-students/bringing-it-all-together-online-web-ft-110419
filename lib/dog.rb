class Dog
  attr_accessor :id, :name, :breed

  def initialize(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
    self.id ||= nil
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
  sql = "DROP TABLE IF EXISTS dogs"
  DB[:conn].execute(sql)
 end

  def save
   sql = <<-SQL
   INSERT INTO dogs (name, breed) VALUES (?, ?)
   SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end


  def self.create(attributes) # takes in a hash of attributes and uses metaprogramming to create a new dog object. Then it uses the #save method to save that dog to the database returns a new dog object
    dog = Dog.new(attributes)
    dog.save
    dog
  end

  def self.new_from_db(row) #creates an instance with corresponding attribute values
    attributes = {
         :id => row[0],
         :name => row[1],
         :breed => row[2]
       }
       self.new(attributes) # return the newly created instance
  end

  def self.find_by_id(id) #returns a new dog object by id
   sql = <<-SQL
   SELECT * FROM dogs
   WHERE id = ?
   SQL

  DB[:conn].execute(sql, id).map do |row|
    self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:,  breed:)
    sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ? AND breed = ?
        SQL


     dog = DB[:conn].execute(sql, name, breed).first

        if dog
          new_dog = self.new_from_db(dog)
        else
          new_dog = self.create({:name => name, :breed => breed})
        end
        new_dog
    end

   def self.find_by_name(name)
    sql = <<-SQL
     SELECT * FROM dogs
     WHERE name = ?
     LIMIT 1
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
