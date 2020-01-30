class Dog

    attr_accessor :name, :breed, :id
   
    def initialize(id:nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
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
        DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
    end

    def save
        if id
            update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?)
            SQL
            DB[:conn].execute(sql, name, breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(hash_attr)
        new_dog = new(hash_attr)
        new_dog.save
        new_dog
    end

    def self.new_from_db(data)
        hash_data = {
        :id => data[0],
        :name => data[1],
        :breed => data[2]
        }
        new(hash_data)
    end

    def self.find_by_id(id)
        DB[:conn].execute("SELECT * FROM dogs WHERE id IS ?", id).map do |data|
            new_from_db(data)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT * FROM dogs 
            WHERE name IS ? AND breed IS ?
        SQL
        dog = DB[:conn].execute(sql, name, breed).first
        if dog
            new_dog = new_from_db(dog)
        else
            new_dog = create({:name => name, :breed => breed})
        end
        new_dog
    end

    def self.find_by_name(name)
        DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).map do |row|
            new_from_db(row)
        end.first
    end

    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", name, breed, id)
    end

end