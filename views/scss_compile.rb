#!/usr/local/bin/ruby
require 'fileutils'

User  = "kyontan"
Group = "www"
  

def scss_compile(from, to, op = "--style expanded")
  puts "Compiling #{from}"
  FileUtils.remove(to) if File.exists?(to)
  `scss #{op} #{from} #{to}`
  FileUtils.chown(User, Group, to)
end

unless ARGV.empty?
	base_folder = File.expand_path(File.dirname(__FILE__)) + ?/
	file_name = base_folder + ARGV[0].match(/[^.]*/)[0]
	from = file_name + ".scss"
	to = file_name + ".css"
	scss_compile(from, to)
		
	exit
end

Dir::glob(File.expand_path(File.dirname(__FILE__)) + "/*.scss").each do |s|
  next if /.*\/_.*?\.scss/ === s
  to = s[0..-6] + ".css"
  scss_compile(s, to)
end
