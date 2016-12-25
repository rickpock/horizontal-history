require_relative 'data.rb'
require_relative 'draw.rb'

figures = find_figures(ARGV)
puts draw(figures)
