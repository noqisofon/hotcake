# -*- mode: ruby; -*-

def watch(pattern)
  found_files = Dir.glob pattern

  yield found_files
end

def echo_and_system(command)
  puts command
  system command
end

watch 'src/scripts/*.ls' do |matching|
  matching.each do |filename|
    echo_and_system "lsc --no-header --bare  --output core/scripts -c #{filename}"
  end
end
