#!/usr/local/bin/ruby

User  = "kyontan"
Group = "www"

op = "-O2" unless ARGV.length.zero?

Dir::glob(File.expand_path(File.dirname(__FILE__)) + "/*.less").each do |s|
	f = s.match(/(.*?)\.less/)[1]
	puts "Compiling #{f}.less"
	`rm #{f}.css`
	`lessc #{op} #{f}.less > #{f}.css`
end
`chown #{User}:#{Group} ./*`
