files = ['demo.txt', 'demo_large.txt', 'input.txt']
file = files[2]

@debug = false

def log(message)
    puts message if @debug
end

class Point

    TwoRoot = Math.sqrt(2)

    attr_accessor :x
    attr_accessor :y

    def initialize(x, y)
        @x = x
        @y = y
    end

    def is_touching(point)
        Math.sqrt((point.x - @x) ** 2 + (point.y - @y) ** 2) <= TwoRoot
    end

    def follow_vector(point)
        if point.x > @x && point.y > @y
            [1, 1]
        elsif point.x < @x && point.y < @y
            [-1, -1]
        elsif point.x > @x && point.y < @y
            [1, -1]
        elsif point.x < @x && point.y > @y
            [-1, 1]
        elsif point.x == @x && point.y > @y
            [0, 1]
        elsif point.x == @x && point.y < @y
            [0, -1]
        elsif point.x > @x && point.y == @y
            [1, 0]
        elsif point.x < @x && point.y == @y
            [-1, 0]
        end
    end

    def direction_vector(command)
        case command[0]
        when 'R'
            [1, 0]
        when 'L'
            [-1, 0]
        when 'U'
            [0, 1]
        else
            [0, -1]
        end
    end

    def add_vector(vector)
        @x += vector[0]
        @y += vector[1]
    end

   def to_a
        [@x, @y]
    end
end

commands = File.readlines(file).map(&:strip).map { _1.split(' ') }

first_rope_length = 2
second_rope_length = 10
# first_rope = Array.new(tail_count + 1).map { Point.new(0, 0) }
# second_rope = Array.new(tail_count + 1).map { Point.new(0, 0) }

rope_data = [
    { :rope => Array.new(first_rope_length).map { Point.new(0, 0) }, :points_visited => [[0, 0]] },
    { :rope => Array.new(second_rope_length).map { Point.new(0, 0) }, :points_visited => [[0, 0]] },
]

rope_data.each { |data|
    commands.each { |command|
        rope = data[:rope]
        points_visited = data[:points_visited]
        log "Command: #{command[0]} #{command[1]}"
        head = rope[0]
        how_many = command[1].to_i
        direction_vector = head.direction_vector(command)
        how_many.times {
            log "Moving head to #{[head.x + direction_vector[0], head.y + direction_vector[1]]}"
            head.add_vector(direction_vector)
            rope.each_with_index { |tail, i|
                next if i == 0
                log "Moving tail #{i} to #{tail.follow_vector(rope[i-1])}" if !tail.is_touching(rope[i-1])
                tail.add_vector(tail.follow_vector(rope[i-1])) if !tail.is_touching(rope[i-1])
                log "Adding point #{tail.to_a} to visited for tail #{i}" if i == rope.length - 1
                points_visited << tail.to_a if i == rope.length - 1
            }
        }
    }
}

puts "First part: #{rope_data[0][:points_visited].uniq.count}"
puts "Second part: #{rope_data[1][:points_visited].uniq.count}"
