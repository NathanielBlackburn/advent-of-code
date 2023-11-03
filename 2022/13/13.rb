require 'json'

files = ['demo.txt', 'input.txt']
file = files[1]

@debug = false

def log(message)
    puts message if @debug
end

def compare(left, right)
    log "Comparing #{left} to #{right}"
    if left.nil? && right.nil?
        log "Same arrays, inconclusive"
        0
    elsif left.nil? && !right.nil?
        log "Left ran out of items, right order"
        1
    elsif !left.nil? && right.nil?
        log "Right ran out of items, NOT right order"
        -1
    elsif left.is_a?(Integer) && right.is_a?(Integer)
        if left < right
            log "Left is smaller, right order"
            1
        elsif left > right
            log "Right is smaller, NOT right order"
            -1
        else
            log "Same values, inconclusive"
            0
        end
    elsif left.is_a?(Array) && right.is_a?(Array)
        index = 0
        log "Comparing elements #{index} in #{left} and #{right}"
        while (result = compare(left[index], right[index])) == 0
            index += 1
            break if left[index].nil? && right[index].nil?
            log "Comparing elements #{index} in #{left} and #{right}"
        end
        result
    elsif left.is_a?(Array) && right.is_a?(Integer)
        log "Left is an array, right is an integer, wrapping right in an array"
        compare(left, [right])
    elsif left.is_a?(Integer) && right.is_a?(Array)
        log "Left is an integer, right is an array, wrapping left in an array"
        compare([left], right)
    end
end

input = File.readlines(file).map(&:strip).reject(&:empty?).map {JSON.parse(_1) }

puts "First half: " + input.each_slice(2).map { |slice|
    compare(slice[0], slice[1])
}.each_with_index.filter { _1[0] == 1 }.map { _1[1] + 1}.sum.to_s

input << [[2]]
input << [[6]]

sorted = input.sort { |l, r| compare(l, r) }.reverse
puts "Second half: #{(sorted.index([[2]]) + 1) * (sorted.index([[6]]) + 1)}"