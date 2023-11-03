files = ['demo.txt', 'input.txt']
file = files[1]

DEBUG = false
@cave_width = 7

module Loggable

    def log(message)
        puts message if ::DEBUG
    end
end


class Jet

    def initialize(pattern)
        @pattern = pattern.split('')
        @queue = @pattern.dup
    end

    def get
        @queue = @pattern.dup if @queue.empty?
        @queue.shift
    end
end


class Point

    attr_reader :x
    attr_reader :y

    def initialize(x, y)
        @x = x
        @y = y
    end

    def moved_by(vector)
        Point.new(@x + vector.x, @y + vector.y)
    end 

    def ==(point)
        self.class == point.class && @x == point.x && @y == point.y
    end

    def eql?(point)
        self.class == point.class && @x == point.x && @y == point.y
    end

    def to_s
        "[#{@x}, #{@y}]"
    end
end

class Vector < Point

    def self.down
        Vector.new(0, -1)
    end

    def self.up
        Vector.new(0, 1)
    end

    def self.left
        Vector.new(-1, 0)
    end

    def self.right
        Vector.new(1, 0)
    end

    def self.jet(direction)
        case direction
        when '<'
            left
        when '>'
            right
        end
    end

    def to_s
        case self
        when Vector::down
            "down"
        when Vector::up
            "up"
        when Vector::left
            "left"
        when Vector::right
            "right"
        else
            "dunno"
        end
    end
end

class Rock

    attr_reader :type
    attr_reader :vectors

    def initialize(type)
        @type = type
        case type
        when :minus
            @vectors = [
                Vector.new(0, 0),
                Vector.new(1, 0),
                Vector.new(2, 0),
                Vector.new(3, 0),
            ]
        when :plus
            @vectors = [
                Vector.new(1, 0),
                Vector.new(0, 1),
                Vector.new(1, 1),
                Vector.new(2, 1),
                Vector.new(1, 2),
            ]
        when :el
            @vectors = [
                Vector.new(0, 0),
                Vector.new(1, 0),
                Vector.new(2, 0),
                Vector.new(2, 1),
                Vector.new(2, 2),
            ]
        when :stick
            @vectors = [
                Vector.new(0, 0),
                Vector.new(0, 1),
                Vector.new(0, 2),
                Vector.new(0, 3),
            ]
        when :box
            @vectors = [
                Vector.new(0, 0),
                Vector.new(1, 0),
                Vector.new(0, 1),
                Vector.new(1, 1),
            ]
        end
    end

    def height
        @vectors.map {|v| v.y }.uniq.count
    end

    def width
        @vectors.map {|v| v.x }.uniq.count
    end
end

class RockGenerator

    @@rocks = [
        Rock.new(:minus),
        Rock.new(:plus),
        Rock.new(:el),
        Rock.new(:stick),
        Rock.new(:box),
    ]

    def self.get
        rock = @@rocks.shift
        @@rocks << rock

        rock
    end
end

class CaveRock < Rock

    include Loggable

    attr_accessor :last_tested
    attr_reader :occupied_points

    def initialize(type, position, cave_width, cycle)
        super(type)
        @position = position
        @cave_width = cave_width
        @last_tested = cycle
    end

    def moved_by(vector)
        CaveRock.new(@type, Point.new(@position.x + vector.x, @position.y + vector.y), @cave_width, @last_tested)
    end

    def move(vector)
        @position = @position.moved_by(vector)
    end

    def topmost
        @position.y + height - 1
    end

    def rightmost
        @position.x + width - 1        
    end

    def occupies?(point)
        @vectors.map { |vector| @position.moved_by(vector) }.include?(point)
    end

    def occupied_points
        @vectors.map { |vector| @position.moved_by(vector) }
    end

    def collides?(rocks, cave_topmost, cycle)
        log "#{self} has rightmost at #{rightmost} with cave width at #{@cave_width}"
        collides_with_rocks = rocks
            .filter { |rock| rock.topmost >= @position.y }
            .any? { |rock|
                intersected_points = rock.occupied_points.intersection(occupied_points).count > 0
                rock.last_tested = cycle if intersected_points
                intersected_points
            }
        collides_with_walls = @position.x < 0 || (rightmost > @cave_width - 1)
        collides_with_floor = @position.y < 0

        collides_with_rocks || collides_with_walls || collides_with_floor
    end

    def collides_with_walls?
        @position.x < 0 || (rightmost > @cave_width - 1)
   end

    def x
        @position.x
    end

    def y
        @position.y
    end

    def to_s
        "#{@type} at #{@position}"
    end
end

class Cave

    include Loggable

    attr_reader :topmost
    attr_reader :rocks_rested
    attr_accessor :cycle

    def initialize(width, jet)
        @width = width
        @rows = [
            Array.new(7).fill('#'),
            Array.new(7).fill('.'),
            Array.new(7).fill('.'),
            Array.new(7).fill('.'),
        ]
        @static_rocks = []
        @moving_rock = nil
        @jet = jet
        @rocks_rested = 0
        @cycle = 0
    end

    def rocks
        [@static_rocks, @moving_rock].flatten.compact
    end

    def printable
        max = topmost
        max = 3 if max < 3
        for y in max.downto(0).to_a
            print '|'
            for x in 0..@width - 1 
                if rocks.any? { |rock| rock.occupies?(Point.new(x, y)) }
                    print '#'
                else
                    print '.'
                end
            end
            puts '|'
        end
        puts '+' + ''.rjust(@width, '-') + '+'
    end

    def add(rock)
        @moving_rock = CaveRock.new(rock.type, Point.new(2, topmost + 4), @width, @cycle)
        @static_rocks = @static_rocks.last(50)
    end

    def topmost
        rocks.map { |r| r.topmost }.max || -1
    end

    def rest
        @static_rocks << @moving_rock
        @moving_rock = nil
        @rocks_rested += 1
    end

    def rested
        @moving_rock.nil?
    end

    def move_rock_down(uncoditionally = false)
        return if @moving_rock.nil?
        down = Vector::down
        log "Trying to move #{@moving_rock} #{down}"
        if uncoditionally
            @moving_rock = @moving_rock.moved_by(down)
        else
            moved_down = @moving_rock.moved_by(down)
            if moved_down.collides?(@static_rocks, topmost, @cycle)
                log "#{@moving_rock} rests"
                rest
            else
                log "#{@moving_rock} goes #{down}"
                @moving_rock = moved_down    
            end
        end
    end

    def move_rock_by_jet(uncoditionally = false)
        direction = Vector::jet(@jet.get)
        log "Trying to move #{@moving_rock} #{direction} by jet"
        if uncoditionally
            moved = @moving_rock.moved_by(direction)
            if !moved.collides_with_walls?
                @moving_rock = moved
            end
        else
            moved = @moving_rock.moved_by(direction)
            log "When moved, the rock will be #{moved}"
            if !moved.collides?(@static_rocks, topmost, @cycle)
                log "#{@moving_rock} goes #{direction}"
                @moving_rock = moved
            else
                log "#{@moving_rock} can't move there"
            end
        end
    end

    def cleanup
        @cycle += 1
        a = @static_rocks.count
        @static_rocks = @static_rocks.filter { |rock|
            # puts "Rock has been last tested on #{rock.last_tested}, now it's #{@cycle}"
            (rock.last_tested - @cycle).abs < 100
        }
        # puts "Cleaned from #{a} to #{@static_rocks.count}"
    end
end

cave = Cave.new(@cave_width, Jet.new(File.readlines(file)[0].strip))

require 'benchmark'

measured = Benchmark.measure {
while cave.rocks_rested < 2022
    if cave.rested
        cave.add(RockGenerator::get) 
        cave.move_rock_by_jet(true)
        cave.move_rock_down(true)
        cave.move_rock_by_jet(true)
        cave.move_rock_down(true)
        cave.move_rock_by_jet(true)
        cave.move_rock_down(true)
    else
        cave.move_rock_by_jet
        cave.move_rock_down
    end
end
}.real

puts "Took #{measured}"

puts cave.topmost + 1