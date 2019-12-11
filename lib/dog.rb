class Dog
  
  attr_accessor :id, :name, :breed
  
  def initialize(id=nil, attributes)
    attributes.each { |key, value| self.send("#{key}=", value) }
  end
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs;
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?);
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    return self
  end
  
  def self.create(attributes)
    dog = self.new(attributes)
    dog.save
    return dog
  end
  
  def self.new_from_db(row)
    return self.new(id: row[0], name: row[1], breed: row[2])
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
      LIMIT 1;
    SQL
    
    dog = DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def self.find_or_create_by(attributes)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
      LIMIT 1;
    SQL
    
    unless DB[:conn].execute(sql, attributes[:name], attributes[:breed])[0]
      return self.new(attributes).save
    else
      DB[:conn].execute(sql, attributes[:name], attributes[:breed]).map do |row|
        self.new_from_db(row)
      end.first
    end
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      LIMIT 1;
    SQL
    
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ?
      WHERE id = ?;
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
end
