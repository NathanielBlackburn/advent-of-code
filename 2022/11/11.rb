files = ['demo.txt', 'input.txt']
file = files[1]

@debug = false

def log(message)
    puts message if @debug
end

class Monkey

    attr_accessor :items
    attr_reader :inspected
    attr_reader :divide_by

    def initialize(items, operation, divide_by, monkey_true, monkey_false, divisor)
        @items = items
        @operation = operation
        @divide_by = divide_by
        @monkey_true = monkey_true
        @monkey_false = monkey_false
        @inspected = 0
        @divisor = divisor
    end

    def inspect_items(divisor_big)
        new_items = @items.map { |worry_level|
            @inspected += 1
            new_worry_level = perform_operation(worry_level) / @divisor
            {
                :worry_level => new_worry_level % (divisor_big == -1 ? new_worry_level + 1 : divisor_big),
                :monkey => new_worry_level % @divide_by == 0 ? @monkey_true : @monkey_false
            }
        }
        @items = []
        new_items
    end

    private

    def perform_operation(worry_level)
        operation = @operation.gsub('old', worry_level.to_s).split(' ')
        if operation[1] == '+'
            operation[0].to_i + operation[2].to_i
        else
            operation[0].to_i * operation[2].to_i
        end
    end
end

def parse_monkey(data, divisor)
    items = data[1].split(':')[1].split(', ').map(&:to_i)
    operation = data[2].match(/(?<=new = ).+/).to_s
    divide_by = data[3].match(/(?<=by ).+/).to_s.to_i
    monkey_true = data[4].split(' ').last.to_i
    monkey_false = data[5].split(' ').last.to_i

    Monkey.new(items, operation, divide_by, monkey_true, monkey_false, divisor)
end

def monkey_cycle(monkeys, divisor_big = -1)
    monkeys.each { |monkey|
        new_items = monkey.inspect_items(divisor_big)
        new_items.each { |item|
            monkeys[item[:monkey]].items << item[:worry_level]
        }
    }
end

monkeys = File.readlines(file).each_slice(7).map { |data| parse_monkey(data, 3) }
20.times { monkey_cycle(monkeys) }
puts "First half: #{monkeys.sort_by { |m| m.inspected }.map(&:inspected).last(2).inject(:*)}"

monkeys = File.readlines(file).each_slice(7).map { |data| parse_monkey(data, 1) }
divisor_big = monkeys.map { |m| m.divide_by }.inject(:*)
10000.times { monkey_cycle(monkeys, divisor_big) }
puts "Second half: #{monkeys.sort_by { |m| m.inspected }.map(&:inspected).last(2).inject(:*)}"
