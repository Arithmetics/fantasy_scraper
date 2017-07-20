class Parent
  attr_accessor :name
  def initialize(name)
    @name = name
  end 
  
  def say
    puts @age
  end
end

class Child < Parent
  attr_accessor :age
  def initialize(name,age)
    super(name)
    @age = age
  end
end

