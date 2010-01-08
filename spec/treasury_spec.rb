require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Treasury
  describe "Treasury" do
    class Thing < Treasure
      def id
        object_id
      end
    end

    it "returns the repository for a class via []" do
      r1 = Treasury[Thing]
      r1.should be_a(Repository)
      Treasury[Thing].should == r1
    end
    
    # but should it?
    it "stores itself in a Thread Local" do 
      @r1 = nil
      @r2 = nil
      Thread.new {@r1 = Treasury[Thing]}
      Thread.new {@r2 = Treasury[Thing]}
      @r1.should_not be_nil
      @r2.should_not be_nil
      @r2.should_not == @r1
    end

    it "can clear all" do
      Treasury[Thing].put([Thing.new, Thing.new])
      Treasury[Thing].size.should == 2
      Treasury.clear_all
      Treasury[Thing].size.should == 0
    end
    
    it "can replace the repository for a given class" do
      new_repository = Repository.new(Thing)
      Treasury[Thing] = new_repository
      Treasury[Thing].should == new_repository
    end
  end
  
  describe "a mixed-in treasury object class" do
    
    class Animal
      extend Treasury
      
      attr_accessor :name
      
      def initialize(name = "animal")
        @name = name
      end
      
      def treasury_key
        object_id
      end

    end
    
    describe 'class methods' do
      before do
        Treasury.clear_all
      end
      
      it 'should have a #treasury_size and #put' do
        Animal.treasury_size.should == 0
        Animal.put(Animal.new, Animal.new)
        Animal.treasury_size.should == 2
      end
      
      it 'should #<<' do
        Animal << Animal.new 
        Animal.treasury_size.should == 1
        Animal << [Animal.new, Animal.new]
        Animal.treasury_size.should == 3
      end
      
      it 'should find the first with id using []' do
        my_animal = Animal.new
        Animal << [Animal.new, my_animal]
        Animal[my_animal.treasury_key].should == my_animal
      end
      
      it 'should have a #search method' do
        find_me = Animal.new
        Animal.put(find_me, Animal.new)
        Animal.search(find_me.treasury_key).should == [find_me]
      end
      
      it '#search accepts a block which uses the factory DSL' do
        otter = Animal.new("otter")
        Treasury[Animal].store.put(otter)
        Animal.search do |q|
          q.equals('name', "otter")
        end.should == [otter]
      end
      
      it 'should #clear_treasury' do
        Animal.put(Animal.new, Animal.new)
        Animal.treasury_size.should == 2 # just to check
        Animal.clear_treasury
        Animal.treasury_size.should == 0
      end
    end
    
    describe 'instance methods' do
      it 'should have a #put method' do
        Treasury.clear_all
        animal = Animal.new
        animal.put
        Animal.treasury_size.should == 1
      end
    end
    
     
  end
end
