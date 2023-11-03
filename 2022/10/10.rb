files = ['demo.txt', 'input.txt']
file = files[1]

log = []
# cycle = 1
x = 1


File.readlines(file).map(&:strip).map(&:split).each { |command|
    if command[0] == 'addx'
        # puts "Cycle #{cycle}, x is #{x}, will add #{command[1].to_i}"
        log << x
        # cycle += 1
        # puts "Cycle #{cycle}, x is #{x}, finishing adding"
        log << x
        x += command[1].to_i
        # cycle += 1
    else
        # puts "Cycle #{cycle}, x is #{x}, doing nothing"
        log << x
        # cycle += 1
    end
}

pixels = ''

sum = 0
log.drop(19).each_with_index { |v, i|
    if i % 40 == 0
        sum += v * (i + 20)
    end
}

log.each_with_index { |v, i|
    if (i % 40) == v || (i % 40) == v-1 || (i % 40) == v+1
        pixels << '#'
    else
        pixels << '.'
    end
    if (i + 1) % 40 == 0
       pixels << "\n"
    end
}

puts sum
# puts log[20] * 20 + log[60] * 60 + log[100] * 100 + log[140] * 140 + log[180] * 180 + log[220] * 220

puts pixels


# puts log[218]