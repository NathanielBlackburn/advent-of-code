sums = []
partial_sum = 0

File.readlines('input.txt').each { |l|
  l.strip!
  if l != ''
    partial_sum += l.to_i
  else
    sums << partial_sum
    partial_sum = 0
  end
}

puts sums.max