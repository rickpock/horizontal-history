require 'Open3'

COL_WIDTH = 30
DECADE_WIDTH = 60
BORDER_WIDTH = 1
YEAR_HEIGHT = 3

def draw_background(start_year, end_year, num_cols)
  start_decade = (start_year.to_f / 10).floor
  end_decade = ((end_year.to_f / 10).ceil - 1)

  num_decades = end_decade - start_decade + 1

  border = "#{BORDER_WIDTH}x#{BORDER_WIDTH}"
  width = DECADE_WIDTH + 2 * BORDER_WIDTH + num_cols * (COL_WIDTH + BORDER_WIDTH)
  size = "#{width}x#{BORDER_WIDTH + (YEAR_HEIGHT * 10) * num_decades}"
  base_command = "convert -size #{size} canvas:white"
  term_command = "-bordercolor black -border #{border} png:-"

  decades = (start_decade..end_decade).to_a
  decade_commands = [] #(0...num_decades).map do |decade_idx|
#    decade = decades[decade_idx]
#    "\\( -bordercolor lightgray -border #{border} -size #{DECADE_WIDTH}x#{YEAR_HEIGHT*10 - BORDER_WIDTH} -gravity center label:'#{decade * 10}' \\) -gravity SouthWest -geometry +0+#{decade_idx * (YEAR_HEIGHT * 10)} -composite"
#  end

  century_commands = []
#  (0...num_decades).each do |decade_idx|
#    decade = decades[decade_idx]
#    if decade % 10 == 0
#      century_commands << %|-fill none -stroke black -draw "stroke-dasharray 5 5 path 'M 0,#{(num_decades - decade_idx) * (YEAR_HEIGHT * 10)} L #{width},#{(num_decades - decade_idx) * (YEAR_HEIGHT * 10)}'"|
#    end
#  end


  # TODO: Add dashed lines at century boundaries

  full_command = base_command + " " + decade_commands.join(" ") + " " + century_commands.join(" ") + " " + term_command

  #image, status = Open3.capture2(full_command)
  #image
  
  width = DECADE_WIDTH + 2 * BORDER_WIDTH + num_cols * (COL_WIDTH + BORDER_WIDTH)
  height = BORDER_WIDTH + (YEAR_HEIGHT * 10) * num_decades
  dp = ImagemagickDP.new(width, height, 'white')
  dp.set_border(BORDER_WIDTH, 'black')
  dp.build
end

CATEGORY_BG_COLORS = {
  :political => "'#66CCFF'",
  :cultural => "'#009999'",
  :religious => "'#000099'",
  :explorer => "'#9999FF'",
  :science => "'#00CC00'",
  :invention => "'#66FFCC'",
  :business => "'#009900'",
  :economics => "darkgray",
  :philosophy => "'#9900CC'",
  :art => "'#FF00FF'",
  :writing => "'#FF0000'",
  :music => "'#FF9933'",
  :entertainment => "'#FFFF00'",
  :sports => "'#996600'"}
CATEGORY_BG_COLORS.default = "lightgray"

CATEGORY_FG_COLORS = {
  :political => "black",
  :cultural => "white",
  :religious => "white",
  :explorer => "white",
  :science => "black",
  :invention => "black",
  :business => "white",
  :economics => "white",
  :philosophy => "white",
  :art => "black",
  :writing => "black",
  :music => "black",
  :entertainment => "black",
  :sports => "white"}
CATEGORY_FG_COLORS.default = "black"

def overlay_figures(base_image, start_year, end_year, figure_columns)
  end_decade = ((end_year.to_f / 10).ceil - 1)
  effective_end_year = (end_decade + 1) * 10

  base_command = "convert -"

  figure_commands = figure_columns.map do |figure, column_idx|

    name = figure[:name]
    birth_year = figure[:birth_year]
    death_year = figure[:death_year]
    background = CATEGORY_BG_COLORS[figure[:category]]
    foreground = CATEGORY_FG_COLORS[figure[:category]]

    "\\( -bordercolor black -border #{BORDER_WIDTH}x#{BORDER_WIDTH} -background #{background} -size #{(death_year - birth_year)*YEAR_HEIGHT - BORDER_WIDTH}x#{COL_WIDTH} -gravity center -fill #{foreground} label:'#{name}' -rotate 90 \\) -gravity NorthWest -geometry +#{DECADE_WIDTH + 3*BORDER_WIDTH + column_idx * (COL_WIDTH + BORDER_WIDTH)}+#{YEAR_HEIGHT*(effective_end_year - death_year) + BORDER_WIDTH} -composite"
  end

  term_command = "-"


  full_command = base_command + " " + figure_commands.join(" ") + " " + term_command

  image, status = Open3.capture2(full_command, :stdin_data=>base_image)
  image
end

# Outputs a map of figure -> column_idx
def assign_columns(figures)
  columns_last_year = []
  figure_columns = {}

  ordered_figures = figures.sort_by {|figure| -figure[:death_year]}
  ordered_figures.each do |figure|
    # Find the first column available through the figures death year
    first_available_column = columns_last_year.find_index {|last_year| last_year >= figure[:death_year]}

    if first_available_column.nil?
      # No column available, add a new one
      figure_columns[figure] = columns_last_year.length
      columns_last_year << figure[:birth_year]
    else
      figure_columns[figure] = first_available_column
      columns_last_year[first_available_column] = figure[:birth_year]
    end
  end

  figure_columns
end

def draw(figures)
  earliest_year = figures.map {|figure| figure[:birth_year]}.min
  latest_year = figures.map {|figure| figure[:death_year]}.max

  figure_columns = assign_columns(figures)
  max_column_idx = figure_columns.values.max
  bg = draw_background(earliest_year, latest_year, max_column_idx + 1)
  #overlay_figures(bg, earliest_year, latest_year, figure_columns)
end

#test = [{:name => "Frank", :birth_year => 1920, :death_year => 1935, :category => :philosophy},
#  {:name => "Annie", :birth_year => 1952, :death_year => 2000, :category => :economics}]
#
#bg = draw_background(1920,1991,test.length)
#
#puts overlay_figures(bg, 1920, 1991, test)
