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
checked_y = 2000000

checks = (extrema[:minx]..extrema[:maxx]).count * data.count
processed = 0

null_points = (extrema[:minx]..extrema[:maxx]).map { |x|
    checked_point = Point.new(x, checked_y)
    print "Processed: #{processed} of #{checks} (#{(processed.to_f / checks * 100).round(2)}%)\r" 
    processed += data.count
    x if data.any? { |pair|
        taxi_distance(pair[:sensor], checked_point) <= pair[:reach] &&
            pair[:beacon] != checked_point &&
            pair[:sensor] != checked_point
    }
}

print ''.rjust(100, ' ') + "\r"
puts null_points.compact.uniq.count