stacks = []
commands = []

File.readlines('input.txt')
    .each { |l|
        if l.start_with?('move')
            commands << l
        elsif l.strip != ''
            chars = l.split('')
            index = 1
            new_line = ''
            while index < chars.length
                new_line << chars[index]
                index += 4
            end
            stacks << new_line
        end
    }

stacks.pop
stacks = stacks.map {|s| s.split('') }.reverse.transpose.map { |v| v.filter { |v| v.strip != '' } }

commands = commands.map { |c|
    c = c.sub('move ', '')
    c = c.sub('from ', '')
    c = c.sub('to ', '')
    c.strip
}

commands.each { |c|
    command = c.split(' ').map(&:to_i)
    how_many = command[0]
    from = command[1] - 1
    to = command[2] - 1
    how_many.times {
        stacks[to] << stacks[from].pop
    }
}

puts stacks.map { |s| s.last }.join('')