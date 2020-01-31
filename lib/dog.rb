class Dog

    attr_accessor :id, :name, :breed
   

    def initialize(id:nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    # def initialize(attributes)
    #     attributes.each {|key, value| self.send(("#{key}="), value)}
    #     self.id ||= nil
    # end
    
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
       DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def save
        if self.id
            self.update 
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

    def self.create(attr_hash)
        new_dog = self.new(attr_hash)
        new_dog.save
        new_dog
    end

    def self.new_from_db(data)
        data_hash = {
            :id => data[0],
            :name => data[1],
            :breed => data[2]
        }
        Dog.new(data_hash)
    end

    def self.find_by_id(id)
        DB[:conn].execute("SELECT * FROM dogs WHERE id IS ?", id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name IS ? AND breed IS ?", name, breed).first
        if dog
            self.new_from_db(dog)
        else
            self.create(:name=>name, :breed=>breed)
        end
    end

    def self.find_by_name(name)
        DB[:conn].execute("SELECT * FROM dogs WHERE name IS ?", name).map do |row|
            new_from_db(row)
        end.first
    end

    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", name, breed, id)
    end

end