require 'securerandom'

files = ['demo.txt', 'input.txt']
file = files[1]

dirs = {}
wd = ''
all_space = 70000000
needed_space = 30000000

File.readlines(file).map(&:strip).each { |l|
    puts '--------------------------------------------------------'
    puts wd
    puts '--------------------------------------------------------'
    if l.start_with?('$')
        print 'Command: '
        l = l[2..-1]
        if l == 'cd ..'
            wd = wd.split('|')[0..-2].join('|')
            puts 'go up'
        elsif l == 'ls'
            puts 'listing'
        elsif new_dir = l.match(/(?<=cd ).+/).to_s
            new_dir_id = SecureRandom.uuid
            dirs[new_dir_id] = {:name => new_dir, :size => 0}
            wd = wd.split('|').push(new_dir_id).join('|')
            puts "go to #{new_dir}"
        end
    elsif l.start_with?('dir')
        puts "Found a directory: #{l.split(' ')[1]}"
    else
        puts "Found a file: #{l.split(' ')[1]}"
        file_size = l.split(' ')[0].to_i
        wd.split('|').each { |d|
            dirs[d][:size] += file_size
        }
    end
}

print "First half: "
puts dirs
    .filter { |id, dir| dir[:size] <= 100000 }
    .values
    .map { |h| h[:size] }
    .sum

print "Second half: "
free_space = all_space - dirs.values.filter { |d| d[:name] == '/' }[0][:size]
space_to_free_up = needed_space - free_space
puts dirs
    .filter { |id, dir| dir[:size] > space_to_free_up }
    .values
    .sort_by { |d| d[:size] }
    .at(0)
    .values_at(:size)[0]