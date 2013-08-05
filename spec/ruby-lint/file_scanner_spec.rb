require 'spec_helper'

describe RubyLint::FileScanner do
  before :all do
    @rails_dir = fixture_path('file_scanner/rails')
    @lib_dir   = fixture_path('file_scanner/lib')
  end

  context 'rails applications' do
    example 'finding a class' do
      scanner = RubyLint::FileScanner.new([@rails_dir])
      paths   = scanner.scan('User')

      paths.should == [
        fixture_path('file_scanner/rails/app/models/user.rb'),
        fixture_path('file_scanner/rails/app/models/example/user.rb')
      ]
    end

    example 'finding a namespaced class' do
      scanner = RubyLint::FileScanner.new([@rails_dir])
      paths   = scanner.scan('Example::User')

      paths.should == [
        fixture_path('file_scanner/rails/app/models/example/user.rb')
      ]
    end
  end

  context 'regular Ruby projects' do
    example 'finding a class' do
      scanner = RubyLint::FileScanner.new([@lib_dir])
      paths   = scanner.scan('Example::User')

      paths.should == [
        fixture_path('file_scanner/lib/example/user.rb')
      ]
    end
  end
end