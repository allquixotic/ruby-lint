require File.expand_path('../../helper', __FILE__)

describe 'Rlint::Scope' do
  it 'Look up a symbol in a scope' do
    scope = Rlint::Scope.new

    scope.lookup(:local_variable, 'number').should == nil

    scope.add(:local_variable, 'number', 10)

    scope.lookup(:local_variable, 'number').should == 10
  end

  it 'Look up a symbol in a parent scope' do
    parent = Rlint::Scope.new
    child  = Rlint::Scope.new(parent)

    parent.add(:local_variable, 'number', 10)
    parent.add(:global_variable, '$number', 20)

    parent.lookup(:local_variable, 'number').should   == 10
    parent.lookup(:global_variable, '$number').should == 20

    child.lookup(:local_variable, 'number').should   == nil
    child.lookup(:global_variable, '$number').should == 20
  end

  it 'Create a scope with default Ruby constants and methods' do
    scope = Rlint::Scope.new(nil, true)
    found = scope.lookup(:constant, 'Kernel')

    found.class.should == Rlint::Scope

    method = found.lookup(:method, 'warn')

    method.class.should == Rlint::Token::MethodDefinitionToken
    method.name.should  == 'warn'

    method.parameters.value.should == [nil]
  end
end
