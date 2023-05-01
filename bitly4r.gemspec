Gem::Specification.new do |s|
    s.required_ruby_version = '>= 3.0'

    s.name = 'bitly4r'
    s.version = '0.2.0'
    # s.date = "2023-04-30"

    s.description = "Bitly4R : A Ruby API for the http://bit.ly URL-shortening service"
    s.summary     = "#{s.name} #{s.version}"

    s.homepage = "http://wiki.cantremember.com/Bitly4R"
    s.authors = ["Dan Foley"]
    s.email = 'admin@cantremember.com'
    s.license = 'WTFPL'

        # = MANIFEST =
  s.files = %w[
    CHANGELOG
    LICENSE
    README.rdoc
    Rakefile
    bitly4r.gemspec
    container
    lib/bitly4r.rb
    lib/bitly4r/client.rb
    lib/bitly4r/definitions.rb
    lib/bitly4r/objects.rb
    test/client_test.rb
    test/definitions_test.rb
    test/objects_test.rb
    test/test_helper.rb
  ]
# = MANIFEST =

    s.files += Dir.glob('lib/**/*.rb')
    # s.test_files = Dir.glob('test/**/*.rb')

    s.require_paths = %w{lib}

    #    only because there ain't no spaces in the title ...
    s.rdoc_options = %w{ --line-numbers --inline-source --title Bitly4R --main README.rdoc }
    s.extra_rdoc_files = %w{ README.rdoc CHANGELOG LICENSE }
end
