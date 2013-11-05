require './lib/codetree.rb'


describe Codetree do

  before :all do

  end

  subject { Codetree }
  specify { subject.should be_an_instance_of Module }
  context Codetree::Operator do
    subject { Codetree::Operator }
    specify { subject.should be_an_instance_of Class }
    context "#initialize" do
      it "should be possible to instanciate an Operator" do
        $operator = subject.new name: :test, type: :defn, ancestors: [:Module, :Class], line: 10, scope: :public
        $operator.instance_variable_get(:@name).should eq :test
        $operator.instance_variable_get(:@type).should eq :defn
        $operator.instance_variable_get(:@ancestors).should == [:Module, :Class]
        $operator.instance_variable_get(:@line).should == 10
        $operator.instance_variable_get(:@scope).should eq :public        
      end
    end
    context "Accessors" do 
      it "should respond to #name" do 
        $operator.respond_to?(:name).should be_true
        $operator.name.should eq :test
      end
      it "should not respond to #name=" do 
        $operator.respond_to?(:name=).should be_false
      end
      it "should respond to #type" do 
        $operator.respond_to?(:type).should be_true
        $operator.type.should eq :defn
      end
      it "should not respond to #type=" do 
        $operator.respond_to?(:type=).should be_false
      end
      it "should respond to #ancestors" do 
        $operator.respond_to?(:ancestors).should be_true
        $operator.ancestors.should == [:Module, :Class] 
      end
      it "should not respond to #ancestors=" do 
        $operator.respond_to?(:ancestors=).should be_false
      end
      it "should respond to #line" do 
        $operator.respond_to?(:line).should be_true
        $operator.line.should == 10
      end
      it "should not respond to #line=" do 
        $operator.respond_to?(:line=).should be_false
      end
      it "should respond to #scope" do 
        $operator.respond_to?(:scope).should be_true
        $operator.scope.should eq :public
      end
      it "should respond to #scope==" do 
        $operator.respond_to?(:scope=).should be_true
        $operator.scope = :private
        $operator.scope.should eq :private
      end
    end
    context "#ancestor" do 
      it "should return the last ancestor of the instance variable @ancestors" do
        $operator.ancestor.should eq :Class
      end
    end
    
    context "#render" do
      it "should return a correct formatted String depending of the type and if ancestors empty" do
        subject.new(name: :test, type: :defn, ancestors: [], line: 10, scope: :public).render.should eq 'test'
        subject.new(name: :test, type: :defs, ancestors: [], line: 10, scope: :public).render.should eq 'test'
        subject.new(name: :Test, type: :class, ancestors: [], line: 10, scope: :public).render.should eq 'Test'
        subject.new(name: :Test, type: :module, ancestors: [], line: 10, scope: :public).render.should eq 'Test'
        subject.new(name: :Test, type: :module, ancestors: [:Module, :Class], line: 10, scope: :public).render.should eq '::Test'
        subject.new(name: :Test, type: :class, ancestors: [:Module, :Class], line: 10, scope: :public).render.should eq '::Test'
        subject.new(name: :test, type: :defn, ancestors: [:Module, :Class], line: 10, scope: :public).render.should eq '#test'
        subject.new(name: :test, type: :defs, ancestors: [:Module, :Class], line: 10, scope: :public).render.should eq '.test'
      end
    end
    
  end
  context Codetree::ParseTree do
    subject { Codetree::ParseTree }
    specify { subject.should be_an_instance_of Class }
  end
  after :all do

  end
end




