pp File.readlines('input.txt')
    .map(&:strip)
    .flat_map { |ranges| ranges.split(',') }
    .flat_map { |range| range.split('-') }
    .map(&:to_i)
    .each_slice(2)
    .to_a
    .map { |range| range[0]..range[1] }
    .each_slice(2)
    .to_a
    .map { |ranges| ranges[0].cover?(ranges[1]) || ranges[1].cover?(ranges[0]) }
    .map { |cover| cover ? 1 : 0}
    .sum
