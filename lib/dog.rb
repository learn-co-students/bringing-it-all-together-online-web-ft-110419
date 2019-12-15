class Dog 
  
  attr_accessor :id, :name, :breed 
  
  def initialize(attr_hash)
    attr_hash.each {|attr, value| self.send("#{attr}=", value)}
    @id ||= nil 
  end 
  
  def self.create_table
    sql = <<-SQL 
    CREATE TABLE IF NOT EXISTS dogs 
    (id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
    );
    SQL
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table 
    sql = <<-SQL 
    DROP TABLE IF EXISTS dogs
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
  
  def self.create(name:, breed:)
    new_dog = Dog.new(name: name, breed: breed)
    new_dog.save
  end 
  
  def self.new_from_db(array)
    id = array[0]
    name = array[1]
    breed = array[2]
    self.new(id: id, name: name, breed: breed)
  end 
  
  def self.find_by_id(num)
    sql = <<-SQL 
    SELECT *
    FROM dogs 
    WHERE id = ?
    LIMIT 1 
    SQL
    DB[:conn].execute(sql, num).map do |row|
      self.new_from_db(row)
    end.first
  end 
  
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else 
      dog = self.create(name: name, breed: breed)
    end 
    dog 
  end 
  
  def self.find_by_name(name)
      DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).map do |row|
      self.new_from_db(row)
    end.first
  end 
  
  def update
     sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 
  
end 