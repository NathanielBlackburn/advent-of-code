def parse_symbol(letter)
    case letter
    when 'A'
        :rock
    when 'B'
        :paper
    when 'X'
        :rock
    when 'Y'
        :paper
    else
        :scissors
    end
end

def get_pairing_score(his, mine)
    if mine == :rock && his == :scissors
        6
    elsif mine == :paper && his == :rock
        6
    elsif mine == :scissors && his == :paper
        6
    elsif mine == his
        3
    else
        0
    end
end

def get_symbol_score(mine)
    case mine
    when :rock
        1
    when :paper
        2
    when :scissors
        3
    end
end

score = 0

File.readlines('input.txt').each { |l|
    pairing = l.split.map { |s| parse_symbol(s) }
    score += get_pairing_score(*pairing)
    score += get_symbol_score(pairing[1])
}

puts score
