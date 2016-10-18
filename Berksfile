source 'https://supermarket.chef.io'

metadata

# Synchronoss Common Cookbooks
common_cookbooks = %w( )

common_cookbooks.each do |cb|
  cookbook cb, git: "ssh://git@stash.synchronoss.net:7999/sncr-cookbooks/#{cb}.git"
end

# group :integration do

# end
