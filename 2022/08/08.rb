files = ['demo.txt', 'input.txt']
file = files[1]

trees = []
visible = 0
max_scenic_score = 0

File.readlines(file).map(&:strip).each { |l|
    trees << l.split('')
}

def find_scenic_score(trees, tree_height)
    first_tree = trees.index { _1 >= tree_height }
    if first_tree == nil
        trees.length
    else
        first_tree + 1
    end
end

forest_width = trees[0].length
forest_height = trees.length

trees.each_with_index { |row, row_index|
    row.each_with_index { |tree_height, column_index|
        if [0, forest_height - 1, forest_width - 1].include?(row_index) || [0, forest_height - 1, forest_width - 1].include?(column_index)
            visible += 1
        else
            if row[0,column_index].none? { _1 >= tree_height } ||
                row[column_index+1..-1].none? { _1 >= tree_height } ||
                trees.transpose[column_index][0,row_index].none? { _1 >= tree_height } ||
                trees.transpose[column_index][row_index+1..-1].none? { _1 >= tree_height }
                visible += 1
            end
            left = find_scenic_score(row[0,column_index].reverse, tree_height)
            right = find_scenic_score(row[column_index+1..-1], tree_height)
            up = find_scenic_score(trees.transpose[column_index][0,row_index].reverse, tree_height)
            down = find_scenic_score(trees.transpose[column_index][row_index+1..-1], tree_height)
            scenic_score = left * right * up * down
            max_scenic_score = scenic_score if scenic_score > max_scenic_score
        end
    }
}

puts "First half: #{visible}"
puts "Second half: #{max_scenic_score}"
