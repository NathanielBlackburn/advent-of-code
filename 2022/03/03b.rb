puts File.readlines('input.txt')
    .map(&:strip)
    .each_slice(3)
    .to_a
    .map { |group|
        group[0].split('') & group[1].split('') & group[2].split('')
    }
    .flat_map { |letter|
        (letter.first.downcase == letter.first) ? (letter.first.ord - 96) : (letter.first.ord - 38)
    }
    .sum 
