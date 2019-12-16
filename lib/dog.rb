class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-sql
    CREATE TABLE dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    sql
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-sql
    DROP TABLE dogs
    sql
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
       sql = <<-SQL
         INSERT INTO dogs (name, breed) VALUES (?, ?)
       SQL
       DB[:conn].execute(sql, self.name, self.breed)
       @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
     end
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
     sql = <<-sql
     SELECT * FROM dogs WHERE id = ? LIMIT 1
     sql
     DB[:conn].execute(sql, id).map do |row|
       self.new_from_db(row)
     end.first
   end

   def self.find_or_create_by(name:, breed:)
     sql = <<-sql
     SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1
     sql
     dog = DB[:conn].execute(sql, name, breed)

     if !dog.empty?
       dog_info = dog[0]
       dog = Dog.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
     else
       dog = self.create(name: name, breed: breed)
     end
     dog
   end

   def self.find_by_name(name)
     sql = <<-sql
     SELECT * FROM dogs WHERE name = ? LIMIT 1
     sql
     DB[:conn].execute(sql, name).map do |row|
       self.new_from_db(row)
     end.first
   end

   def update
     sql = <<-sql
     UPDATE dogs SET name = ?, breed = ? WHERE id = ?
     sql
     DB[:conn].execute(sql, self.name, self.breed, self.id)
   end 
end
