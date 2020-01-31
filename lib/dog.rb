class Dog

    attr_accessor :id, :name, :breed

    def initialize(id:nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        # sql = <<-SQL
        # DROP TABLE IF EXISTS dogs 
        # SQL
        # DB[:conn].execute(sql)
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")

    end

    def save 
        sql = <<-SQL
        INSERT INTO dogs(name, breed) VALUES (?,?)
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

    def self.new_from_db(attrs)
        attr_hash = {
        :id => attrs[0],
        :name => attrs[1],
        :breed => attrs[2]
    }
        Dog.new(attr_hash)
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
        SQL
        DB[:conn].execute(sql, id).map do |row|
            new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT * FROM dogs 
        WHERE name = ? AND breed = ?
        SQL
        result = DB[:conn].execute(sql, name, breed).first
        if result
            new_from_db(result)
        else
         self.create(name: name, breed: breed)
        end
    end

        def self.find_by_name(name) sql = <<-SQL
            SELECT * FROM dogs
            WHERE name= ?
            SQL
            DB[:conn].execute(sql, name).map do |row|
                new_from_db(row)
            end.first
         end

    def update
        sql = <<-SQL
        UPDATE dogs 
        SET name = ?, breed = ?
        WHERE id = ?
        SQL

        DB[:conn].execute(sql, name, breed, id)
    end

end
    
    


 

