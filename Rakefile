require 'rubygems'
require 'rake/clean'
require 'fileutils'

task :default => :test

# SPECS ===============================================================

desc 'Run specs with unit test style output'
task :test => FileList['test/*_test.rb'] do |t|
	suite = t.prerequisites.join(' ')
	sh "ruby -Ilib:test #{suite}", :verbose => false
end

# PACKAGING ============================================================

# Load the gemspec using the same limitations as github
def spec
	@spec ||=
		begin
			require 'rubygems/specification'
			data = File.read('bitly4r.gemspec')
			spec = nil
			#	OS X didn't like SAFE = 2
			#		(eval):25:in `glob': Insecure operation - glob
			Thread.new { spec = eval("$SAFE = 2\n#{data}") }.join
			spec
		end
end

def package(ext='')
	"dist/bitly4r-#{spec.version}" + ext
end

desc 'Build packages'
task :package => %w[.gem .tar.gz].map {|e| package(e)}

desc 'Build and install as local gem'
task :install => package('.gem') do
	sh "gem install #{package('.gem')}"
end

directory 'dist/'

file package('.gem') => %w[dist/ bitly4r.gemspec] + spec.files do |f|
	sh "gem build bitly4r.gemspec"
	mv File.basename(f.name), f.name
end

file package('.tar.gz') => %w[dist/] + spec.files do |f|
	sh "git archive --format=tar HEAD | gzip > #{f.name}"
end

# Release / Publish Tasks ==================================

desc 'Publish website to rubyforge'

# https://guides.rubygems.org/publishing/#publishing-to-rubygemsorg
task 'publish:gem' => [package('.gem')] do |t|
	sh <<-end
		gem push #{package('.gem')}
	end
end

# Website ============================================================
# Building docs

=begin
NOTE:  i honestly don't know how `rake doc` is working
  but it does!

Manual process for publish to Github Pages
  http://cantremember.github.io/bitly4r/

```bash
# no outstanding Git changes, then ...
rake doc

git checkout gh-pages
cp -r doc/* .
git add .

# commit & push
```
=end

task 'doc'     => ['doc:api']

desc 'Generate RDoc under doc/api'
task 'doc:api' => ['doc/api/index.html']

file 'doc/api/index.html' => FileList['lib/**/*.rb','README.rdoc','CHANGELOG','LICENSE'] do |f|
	rb_files = f.prerequisites
	sh((<<-end).gsub(/\s+/, ' '))
		rdoc --line-numbers --inline-source --title Bitly4R --main README.rdoc
			#{rb_files.join(' ')}
	end
end
CLEAN.include 'doc/api'

# Gemspec Helpers ====================================================

file 'bitly4r.gemspec' => FileList['{lib,test}/**','Rakefile'] do |f|
	# read spec file and split out manifest section
	spec = File.read(f.name)
	parts = spec.split("# = MANIFEST =\n")
	fail 'bad spec' if parts.length != 3
	# determine file list from git ls-files
	files = `git ls-files`.
		split("\n").
		sort.
		reject{ |file| file =~ /^\./ }.
		reject { |file| file =~ /^doc/ }.
		map{ |file| "    #{file}" }.
		join("\n")
	# piece file back together and write...
	parts[1] = "  s.files = %w[\n#{files}\n  ]\n"
	spec = parts.join("# = MANIFEST =\n")
	File.open(f.name, 'w') { |io| io.write(spec) }
	puts "updated #{f.name}"
end
