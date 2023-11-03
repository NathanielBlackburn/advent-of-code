def parse_symbol(letter)
    case letter
    when 'A'
        :rock
    when 'B'
        :paper
    when 'C'
        :scissors
    when 'X'
        :lose
    when 'Y'
        :draw
    else
        :win
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

def match_result(his, expected)
    if expected == :draw
        his
    elsif expected == :win
        case his
        when :rock
            :paper
        when :scissors
            :rock
        else
            :scissors
        end
    else
        case his
        when :rock
            :scissors
        when :paper
            :rock
        else
            :paper
        end
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
    strategy = l.split.map { |s| parse_symbol(s) }
    pairing = [strategy[0], match_result(*strategy)]
    score += get_pairing_score(*pairing)
    score += get_symbol_score(pairing[1])
}

puts score
