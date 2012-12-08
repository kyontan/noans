#!/usr/local/bin/ruby

User  = "kyontan"
Group = "www"

Dir::glob("*.less").each do |s|
	f = s.match(/(.*?)\.less/)[1]
	`lessc #{f}.less #{f}.css`
end
`chown #{User}:#{Group} ./*`
