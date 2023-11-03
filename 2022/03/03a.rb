puts File.readlines('input.txt')
    .map(&:strip)
    .map { |l|
        l.split('').take(l.length / 2) & l.split('').reverse.take(l.length / 2)
    }
    .flat_map { |letter|
        (letter.first.downcase == letter.first) ? (letter.first.ord - 96) : (letter.first.ord - 38)
    }
    .sum
