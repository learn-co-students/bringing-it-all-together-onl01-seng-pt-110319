class Dog
    attr_accessor :id, :name, :breed

    def initialize(attributes)
        attributes.each {|key, value| self.send(("#{key}="), value)}
        self.id ||= nil
    end

    def self.create_table
        sql =  <<-SQL 
          CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY, 
            name TEXT, 
            breed TEXT
            )
            SQL
        DB[:conn].execute(sql) 
    end

    def self.drop_table
        sql =  <<-SQL 
         DROP TABLE dogs;
        SQL
        DB[:conn].execute(sql) 
    end

    def save
        sql = <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)    
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(attributes)
        new_dog = Dog.new(attributes)
        new_dog.save
        new_dog
    end

    def self.new_from_db(row)
        hash = {
            :id => row[0],
            :name => row[1],
            :breed => row[2]
        }
        Dog.new(hash)
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
        SQL
        result = DB[:conn].execute(sql, id)[0]
        new_dog = self.new_from_db(result)
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
          SELECT * FROM dogs
          WHERE name = ? AND breed = ?
          SQL
          result = DB[:conn].execute(sql, name, breed).first
    
          if result
            new_dog = self.new_from_db(result)
          else
            new_dog = self.create({:name => name, :breed => breed})
          end
          new_dog
    end
    
    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
        SQL
    
        DB[:conn].execute(sql, name).map do |row|
          self.new_from_db(row)
        end.first
    end

    def update
        sql = <<-SQL
          UPDATE dogs SET name = ?, breed = ? WHERE id = ?
          SQL
    
          DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
    
end