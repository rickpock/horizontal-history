require_relative 'data.rb'
require_relative 'draw.rb'
require_relative 'imagemagick_dp.rb'

# Parse arguments
figure_names = ARGV.reject {|arg| arg.start_with?(":") || arg.start_with?("-")}
figure_categories = ARGV.select {|arg| arg.start_with? ":"}.map {|arg| arg[1..-1].to_sym}
args = ARGV.select {|arg| arg.start_with? "-"}.map {|arg| arg[1..-1]}

# Specifies code to call for each drawing provider
# This allows us to avoid dependencies if we're not using a specific drawing provider
provider_dependencies =
  {
    "SvgDP" => Proc.new do
      require_relative 'svg_dp.rb'
    end,

    "ImagemagickDP" => Proc.new do
      require_relative 'imagemagick_dp.rb'
    end,

    nil => Proc.new do
      STDERR.puts "Invalid drawing provider."
      exit
    end,
  }

# Determine drawing provider based on specified output file format
# The provider_name should exactly match the class name of the provider
provider_name = if args.include? "svg"
             "SvgDP"
           elsif args.include? "png"
             "ImagemagickDP"
           else
             "SvgDP"
           end

provider_dependencies[provider_name].call

figures = find_figures(figure_names, figure_categories)
puts draw(provider_name, figures)
