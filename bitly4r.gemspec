Gem::Specification.new do |s|
	s.specification_version = 2 if s.respond_to? :specification_version=
	s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
	s.required_ruby_version = '>= 1.8'

	s.name = 'bitly4r'
	s.version = '0.1.0'
	s.date = "2009-02-02"

	s.description = "Bit.ly-4R : A Ruby API for the http://bit.ly URL-shortening service"
	s.summary     = "#{s.name} #{s.version}"

	s.authors = ["Dan Foley"]
	s.email = 'admin@cantremember.com'

	# = MANIFEST =
	s.files = %w{
		CHANGELOG
		LICENSE
		README.rdoc
		Rakefile
	}
	s.files << Dir.glob('lib/*')
	s.test_files = Dir.glob('test/*')
	# = MANIFEST =

	s.test_files = s.files.select {|path| path =~ /^test\/.*_test.rb/}

	s.extra_rdoc_files = %w{README.rdoc CHANGELOG LICENSE}
	s.add_dependency 'rack', '>= 0.4.0'

	s.has_rdoc = true
	s.homepage = "http://wiki.cantremember.com/Bitly4R"
	s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Bit.ly-4R", "--main", "README.rdoc"]
	s.require_paths = %w{lib}

	s.rubyforge_project = 'bitly4r'
	s.rubygems_version = '1.1.1'

end
