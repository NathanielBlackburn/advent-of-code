files = ['demo.txt', 'input.txt']
file = files[1]

DEBUG = ARGV[0] == '-d'

module Loggable

    def log(message)
        puts message if ::DEBUG
    end

    def ppr(what)
        pp what if ::DEBUG
    end
end

include Loggable

def pos(i, j, l)
    if j >= 0
        new_pos = i + j
    else
        new_pos = i + (l + j) - 1
    end

    return new_pos % l + 1 if new_pos >= l

    new_pos
end

def get_pos(i, l, start)
    (i % l + start) % l
end
    
numbers = File.readlines(file).map(&:strip).map(&:to_i).each_with_index.map { |n, i|
    { :v => n, :opos => i }
}

new_numbers = numbers.dup

l = numbers.count

ppr new_numbers.map { _1[:v] }

l.times { |c|
    old_index = new_numbers.index { _1[:opos] == c }
    new_pos = pos(old_index, new_numbers[old_index][:v], l)
    log "Moving #{new_numbers[old_index][:v]} at index #{old_index} (orig: #{new_numbers[old_index][:opos]}) to pos #{new_pos}"
    el = new_numbers.delete_at(old_index)
    new_numbers.insert(new_pos, el)
    ppr new_numbers.map { _1[:v] }
}

new_numbers = new_numbers.map { _1[:v] }
zero_index = new_numbers.index(0)

puts new_numbers[get_pos(1000, l, zero_index)] + new_numbers[get_pos(2000, l, zero_index)] + new_numbers[get_pos(3000, l, zero_index)]
