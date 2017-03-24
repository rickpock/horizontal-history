require_relative 'data.rb'
require_relative 'draw.rb'
require_relative 'imagemagick_dp.rb'

figure_names = ARGV.reject {|arg| arg.start_with? ":"}
figure_categories = ARGV.select {|arg| arg.start_with? ":"}.map {|arg| arg[1..-1].to_sym}
figures = find_figures(figure_names, figure_categories)
puts draw(figures)
