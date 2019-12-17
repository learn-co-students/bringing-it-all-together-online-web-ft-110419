require "pry"
class Dog 
  attr_accessor :name, :breed, :id
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
    id INT PRIMARY KEY,
    name TEXT,
    breed TEXT)
      SQL
    DB[:conn].execute(sql)
  end
  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end
  def save
    sql = <<-SQL
    INSERT INTO dogs(name,breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql,name,breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id: id, name: name, breed: breed)
  end
  def self.find_by_id(id)
    
    DB[:conn].execute( "SELECT * FROM dogs WHERE id = ? LIMIT 1",id).map do |row|
      self.new_from_db(row)
    end.first
  end
  def self.find_or_create_by(name:,breed:)
  
     dog = DB[:conn].execute(" SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
     
     if !dog.empty?
       dog_data = dog[0]
      dog = self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else 
      self.create(name: name, breed: breed)
    end
  end
  def self.find_by_name(name)
    dog=DB[:conn].execute("SELECT * FROM dogs WHERE name = ?",name).flatten
    self.new_from_db(dog)
  end
  def update
     DB[:conn].execute('UPDATE dogs SET breed = ?, name = ? WHERE id = ?', self.breed, self.name, self.id)
  end
end