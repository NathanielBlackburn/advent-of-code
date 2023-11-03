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

    def to_s
        "[#{@x}, #{@y}]"
    end

    def moved_by(point)
        Point.new(point.x, point.y)
    end

    def ==(other)
    self.class == other.class &&
        @x == other.x &&
        @y == other.y
    end
end

def find_extrema(data)
    xes = data.flat_map { |d| [d[:sensor].x - d[:reach], d[:sensor].x + d[:reach], d[:beacon].x]  }
    ys = data.flat_map { |d| [d[:sensor].y - d[:reach], d[:sensor].y + d[:reach], d[:beacon].y]  }

    {
        :minx => xes.min,
        :maxx => xes.max,
        :miny => ys.min,
        :maxy => ys.max
    } 
end

def transpose(data, extrema)
    data.map { |d|
        {
            :sensor => Point.new(d[:sensor].x - extrema[:minx], d[:sensor].y - extrema[:miny]),
            :beacon => Point.new(d[:beacon].x - extrema[:minx], d[:beacon].y - extrema[:miny])
        }
    }
end

def taxi_distance(p1, p2)
    (p1.x - p2.x).abs + (p1.y - p2.y).abs
end

def find_sensor_reach(sensor, reach)
    left_reach = sensor.x - reach
    right_reach = sensor.x + reach
    top_reach = sensor.y - reach
    points = (left_reach..right_reach).map { |x|
        Point.new(x, sensor.y)
    }
    (top_reach..(sensor.y - 1)).each { |y|
        ((left_reach + (sensor.y - y))..(right_reach - (sensor.y - y))).each { |x|
            points << Point.new(x, y)
            points << Point.new(x, 2 * sensor.y - y)
        }
    }

    points
end

def sensors_reach_points(sensor, reach)
    left_reach = sensor.x - reach
    right_reach = sensor.x + reach
    top_reach = sensor.y - reach
    width = right_reach - left_reach + 1
    (1 + width - 2) * reach + width
end

data = File.readlines(file).map(&:strip).flat_map { |l|
    sensor_match = l.match(/(?:Sensor at x=)(-?\d+)(?:, y=)(-?\d+)/)
    beacon_match = l.match(/(?:beacon is at x=)(-?\d+)(?:, y=)(-?\d+)/)
    sensor_coords = Point.new(sensor_match[1].to_i, sensor_match[2].to_i)
    beacon_coords = Point.new(beacon_match[1].to_i, beacon_match[2].to_i)
    {
        :sensor => sensor_coords,
        :beacon => beacon_coords,
        :reach => taxi_distance(sensor_coords, beacon_coords)
    }
}

extrema = find_extrema(data)

fieldx = 4000000
fieldy = 4000000

x = 0
y = 0

while true
    point = Point.new(x, y)
    break if x > fieldx && y > fieldy
    sensor = data.find { |d| d[:reach] >= taxi_distance(d[:sensor], point) }

    break if !sensor

    skippedx = sensor[:reach] - taxi_distance(sensor[:sensor], point) + 1
    nextx = x + skippedx
    x = (nextx > fieldx) ? 0 : nextx
    y = (nextx > fieldx) ? y + 1 : y
    print "#{x} #{y} (#{(y.to_f / 4000000 * 100).round(2)})%\r"
end

puts "The frequency is #{x * 4000000 + y}"