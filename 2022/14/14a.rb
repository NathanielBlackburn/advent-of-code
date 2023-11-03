files = ['demo.txt', 'input.txt']
file = files[1]

@debug = false

def log(message)
    puts message if @debug
end

class Point

    attr_accessor :x
    attr_accessor :y

    def initialize(x, y)
        @x = x
        @y = y
    end

    def moved_by(vector)
        Point.new(@x + vector.x, @y + vector.y)
    end

    def bottom_left
        Point.new(@x - 1, @y + 1)
    end

    def bottom_right
        Point.new(@x + 1, @y + 1)
    end

    def bottom
        Point.new(@x, @y + 1)
    end

    def to_s
        "[#{@y},#{@x}]"
    end

end

class Vector < Point

    Zero = Vector.new(0, 0)
end

def whatis(cave, point)
    if (point.y > cave.count - 1) || (point.x < 0) || (point.x > (cave[point.y].count - 1))
        return :wall    
    end
    case cave[point.y][point.x]
    when '#'
        :rock
    when 'o'
        :sand
    when '.'
        :nothing
    end
end

def line_direction(start, ending)
    x = ending.x - start.x
    y = ending.y - start.y
    if x > 0
        Vector.new(1, 0)      
    elsif x < 0
        Vector.new(-1, 0)
    elsif y > 0
        Vector.new(0, 1)
    else
        Vector.new(0, -1)
    end
end

def line_length(start, ending)
    x = (ending.x - start.x).abs
    y = (ending.y - start.y).abs

    x > 0 ? x : y
end

def translate_coords(coords_list)
    flattened = coords_list.flatten
    min_x = flattened.map { _1.x }.min
    translated = coords_list.map { |coords_line|
        log "Translating by #{-1 * min_x}, #{0}"
        coords_line.map { |coords| Point.new(coords.x - min_x, coords.y) }
    }
    [translated, min_x]
end

def max_coords(coords_list)
    flattened = coords_list.flatten
    max_x = flattened.map { _1.x }.max + 1
    max_y = flattened.map { _1.y }.max + 1
    [max_x, max_y]
end

def prepare_cave(coords_list, max_x, max_y)
    cave = Array.new(max_y).map { |l| Array.new(max_x).fill('.') }
    coords_list.each { |coords_line|
        starting_point = coords_line.shift
        while ending_point = coords_line.shift
            log "Drawing a line from #{starting_point} to #{ending_point}"
            add_object(cave, starting_point, :rock)
            log "Drawing a point at #{starting_point}"
            line_direction = line_direction(starting_point, ending_point)
            line_length = line_length(starting_point, ending_point)
            log "Line direction: #{line_direction}"
            log "Line length: #{line_length}"
            drawing_point = starting_point.moved_by(line_direction)
            line_length.times {
            log "Drawing a point at #{drawing_point}"
                add_object(cave, drawing_point, :rock)
                drawing_point = drawing_point.moved_by(line_direction)
            }
            log "Line finished"
            starting_point = ending_point
        end
    }

    cave
end

def print_cave(cave)
    puts
    puts
    print '    '
    cave[0].count.times { |n|
        if n % 10 == 0
            print n / 10
        else
            print n % 10
        end
    }
    puts
    cave.each_with_index { |line, index|
        puts '   ' + index.to_s + line.join('')
    }
end

def add_object(cave, point, object)
    cave[point.y][point.x] = case object
    when :rock
        '#'
    when :sand
        'o'
    else
        '.'
    end
end

def remove_object(cave, point)
    add_object(cave, point, :nothing)
end

coords_list = File.readlines(file)
    .map(&:strip)
    .map { |l|
        l.split(' -> ')
            .map { |c|
                c.split(',')
            }.map { |a| Point.new(a[0].to_i - 500, a[1].to_i) }
    }


coords_list, min_x = translate_coords(coords_list)
max_x, max_y = max_coords(coords_list)
cave = prepare_cave(coords_list, max_x, max_y)
sand_point = Point.new(0 - min_x, 0)

sand_unit = nil
sand_units = 0

require 'benchmark'

puts "Took: " + Benchmark.measure {
    while true
        if sand_unit
            if whatis(cave, sand_unit.bottom) == :wall ||
                whatis(cave, sand_unit.bottom_left) == :wall ||
                whatis(cave, sand_unit.bottom_right) == :wall
                sand_units -= 1
                remove_object(cave, sand_unit)
                break
            end
            if whatis(cave, sand_unit.bottom) == :nothing
                log "Moving sand unit to #{sand_unit.bottom}"
                remove_object(cave, sand_unit)
                sand_unit = sand_unit.bottom
                add_object(cave, sand_unit, :sand)
            elsif whatis(cave, sand_unit.bottom_left) == :nothing
                log "Moving sand unit to #{sand_unit.bottom_left}"
                remove_object(cave, sand_unit)
                sand_unit = sand_unit.bottom_left
                add_object(cave, sand_unit, :sand)
            elsif whatis(cave, sand_unit.bottom_right) == :nothing
                log "Moving sand unit to #{sand_unit.bottom_right}"
                remove_object(cave, sand_unit)
                sand_unit = sand_unit.bottom_right
                add_object(cave, sand_unit, :sand)
            else
                log "No place for sand unit, resting"
                sand_unit = nil
            end
        else
            break if whatis(cave, sand_point) == :sand
            log "Creating sand unit at #{sand_point}"
            sand_unit = sand_point.moved_by(Vector::Zero)
            sand_units += 1
            add_object(cave, sand_unit, :sand)
        end
    end
}.real.round(2).to_s + "s"

puts "Sand units: #{sand_units}"
# print_cave(cave)