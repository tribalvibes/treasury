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

    it "can clear all" do
      Treasury[Thing].store([Thing.new, Thing.new])
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
        Animal.store(Animal.new, Animal.new)
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
        Animal.store(find_me, Animal.new)
        Animal.search(find_me.treasury_key).should == [find_me]
      end
      
      it '#search accepts a block which uses the factory DSL' do
        otter = Animal.new("otter")
        Treasury[Animal].storage.store(otter)
        Animal.search do |q|
          q.equals('name', "otter")
        end.should == [otter]
      end
      
      it 'should #clear_treasury' do
        Animal.store(Animal.new, Animal.new)
        Animal.treasury_size.should == 2 # just to check
        Animal.clear_treasury
        Animal.treasury_size.should == 0
      end
    end
    
  end
end
