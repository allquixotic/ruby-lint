require 'spec_helper'

describe RubyLint::FileScanner do
  before :all do
    @rails_dir = fixture_path('file_scanner/rails')
    @lib_dir   = fixture_path('file_scanner/lib')
  end

  context '#initialize' do
    before do
      @scanner = described_class.new
    end

    example 'raise when a non enumerable argument is given' do
      lambda { described_class.new(10) }.should raise_error(TypeError)
    end

    example 'set the default directories' do
      @scanner.directories.empty?.should == false
    end

    example 'do not include non existing directories' do
      app = File.join(Dir.pwd, 'app')

      @scanner.directories.include?(app).should == false
    end
  end

  context '#glob_ruby_files' do
    example 'glob Ruby source files in a single directory' do
      scanner = described_class.new([@lib_dir])

      scanner.glob_ruby_files.empty?.should == false
    end

    example 'glob Ruby source files in multiple directories' do
      scanner = described_class.new([@lib_dir, @rails_dir])

      scanner.glob_ruby_files.empty?.should == false
    end
  end

  context '#scan' do
    example 'finding a class' do
      scanner = described_class.new([@lib_dir])
      paths   = scanner.scan('Example::User')

      paths.should == [fixture_path('file_scanner/lib/example/user.rb')]
    end

    example 'finding a class using dashes for the directory names' do
      scanner = described_class.new([@lib_dir])
      paths   = scanner.scan('TestDashes::Foo')

      paths.should == [fixture_path('file_scanner/lib/test-dashes/foo.rb')]
    end

    example 'finding a class using a Rails structure' do
      scanner = described_class.new([@rails_dir])
      paths   = scanner.scan('User')

      paths.should == [
        fixture_path('file_scanner/rails/app/models/user.rb'),
        fixture_path('file_scanner/rails/app/models/example/user.rb')
      ]
    end

    example 'finding a namespaced class using a Rails structure' do
      scanner = described_class.new([@rails_dir])
      paths   = scanner.scan('Example::User')

      paths.should == [
        fixture_path('file_scanner/rails/app/models/example/user.rb')
      ]
    end

    example 'ignoring directories' do
      scanner = described_class.new([@lib_dir], [@lib_dir])

      scanner.scan('Example::User').empty?.should == true
    end

    example 'do not scan when there are no directories' do
      scanner = described_class.new([])

      scanner.should_not receive(:glob_ruby_files)

      scanner.scan('Foo')
    end
  end

  context '#constant_to_path' do
    before do
      @scanner = described_class.new([@lib_dir])
    end

    example 'return the path for a single constant segment' do
      @scanner.constant_to_path('Foo').should == 'foo.rb'
    end

    example 'return the path for two constant segments' do
      @scanner.constant_to_path('Foo::Bar').should == 'foo/bar.rb'
    end

    example 'return the path for three constant segments' do
      @scanner.constant_to_path('Foo::Bar::Baz').should == 'foo/bar/baz.rb'
    end

    example 'snake case the constant names' do
      @scanner.constant_to_path('FooBar').should == 'foo_bar.rb'
    end
  end

  context '#constant_to_dashed_path' do
    before do
      @scanner = described_class.new([@lib_dir])
    end

    example 'return the path for a single constant segment' do
      @scanner.constant_to_dashed_path('RubyLint').should == 'ruby_lint.rb'
    end

    example 'return the path for two constant segments' do
      @scanner.constant_to_dashed_path('RubyLint::FooBar')
        .should == 'ruby-lint/foo_bar.rb'
    end

    example 'return the path for three constant segments' do
      @scanner.constant_to_dashed_path('RubyLint::FooBar::BazBaz')
        .should == 'ruby-lint/foo_bar/baz_baz.rb'
    end
  end

  context '#build_constant_paths_cache' do
    before do
      @scanner = described_class.new([@rails_dir])
    end

    example 'build an empty cache for a missing constant' do
      @scanner.build_constant_paths_cache('FoobarDoesNotExist').should be_empty
    end

    example 'build the cache for a User class' do
      cache = @scanner.build_constant_paths_cache('User')

      cache.should == [
        fixture_path('file_scanner/rails/app/models/user.rb'),
        fixture_path('file_scanner/rails/app/models/example/user.rb')
      ]
    end
  end
end
