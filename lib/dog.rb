require "pry"
class Dog 
  attr_accessor :name, :breed, :id
  def initialize(hash,id=nil)
    @id = id
    @name = hash[:name]
    @breed = hash[:breed]
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
    Dog.new(id: id, name: name, breed: breed)
  end
end