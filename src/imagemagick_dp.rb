require 'Open3'

# ImageMagick Drawing Provider
class ImagemagickDP
private
  # Parameters specifying all of the drawing primitives
  @drawing_command = ""

  # Properties of the canvas
  @size = ""
  @bg_color = ""
  @border_color = ""
  @border_size = ""

  DEFAULT_BG_COLOR = 'white'
  DEFAULT_BORDER_COLOR = 'black'

  # Valid x_align values are {"left", "middle", "right"}
  # Valid y_align values are {"top", "center", "bottom"}
  #
  # Possible gravity values are "center" + each of the eight cardinal directions
  def determine_gravity(x_align, y_align)
    case x_align
    when :left
      case y_align
      when :top
        "NorthWest"
      when :center
        "West"
      when :bottom
        "SouthWest"
      else
        "West"  # If they've specified left or right, but not y-alignment, default to centered vertically
      end
    
    when :middle
      case y_align
      when :top
        "North"
      when :center
        "center"
      when :bottom
        "South"
      else
        "North" # If they've specified middle x-alignment, but no y-alignment, default to the top
      end

    when :right
      case y_align
      when :top
        "NorthEast"
      when :center
        "East"
      when :bottom
        "SouthEast"
      else
        "East"  # If they've specified left or right, but not y-alignment, default to centered vertically
      end

    else
      case y_align
      when :top
        "North"  # If they've specified top or bottom, but not x-alignment, default to centered horizontally
      when :center
        "West"  # If they've specified center y-alignment, but no x-alignment, default to the left
      when :bottom
        "South"  # If they've specified top or bottom, but not x-alignment, default to centered horizontally
      else
        "NorthWest" # If no alignment is specified, default to top-left
      end
    end
  end

public
  def initialize(width, height, bg_color = DEFAULT_BG_COLOR)
    @size = "#{width}x#{height}"
    @bg_color = bg_color
    @border_color = "black"
    @border_size = "0x0"
  end

  def set_border(thickness, color = DEFAULT_BORDER_COLOR)
    @border_color = color
    @border_size = "#{thickness}x#{thickness}"
    self
  end

  # position:
  # * x
  # * y
  # * x_align
  # * y_align
  # * width
  # * height
  #
  # settings:
  # * border_thickness
  # * border_color
  # * bg_color
  # * text_x_align
  # * text_y_align
  def draw_text(position, text, settings = {}, transform = {})
    # TODO: Support transforms

    # Extract parameters from `position`
    pos_gravity = determine_gravity(position[:x_align], position[:y_align])

    x = position[:x] || 0
    y = position[:y] || 0

    width = position[:width]
    height = position[:height]
    size_expr = width.nil? || height.nil? ? "" : "-size #{width}x#{height} "

    # Extract parameters from `settings`
    text_gravity = determine_gravity(settings[:text_x_align], settings[:text_y_align])

    border_color = settings[:border_color]
    border_thickness = settings[:border_thickness] || 0
    border_expr = border_color.nil? ? "" : "-bordercolor #{border_color} -border #{border_thickness}x#{border_thickness} "

    bg_color = settings[:bg_color]
    bg_expr = bg_color.nil? ? "" : "-background #{bg_color} "

    # Build command for drawing
    text_command = "\\( #{border_expr}#{bg_expr}#{size_expr}-gravity #{text_gravity} label:'#{text}' \\) -gravity #{pos_gravity} -geometry +#{x}+#{y} -composite"
    @drawing_command = "#{@drawing_command}#{text_command} "

    # Return self to support the builder pattern
    self
  end

  def build()
    command = "convert -size #{@size} canvas:#{@bg_color} #{@drawing_command} -bordercolor #{@border_color} -border #{@border_size} png:-"
    image, status = Open3.capture2(command)
    image
  end
end
#
#def draw_background(start_year, end_year, num_cols)
#  start_decade = (start_year.to_f / 10).floor
#  end_decade = ((end_year.to_f / 10).ceil - 1)
#
#  num_decades = end_decade - start_decade + 1
#
#  border = "#{BORDER_WIDTH}x#{BORDER_WIDTH}"
#  width = DECADE_WIDTH + 2 * BORDER_WIDTH + num_cols * (COL_WIDTH + BORDER_WIDTH)
#  size = "#{width}x#{BORDER_WIDTH + (YEAR_HEIGHT * 10) * num_decades}"
#  base_command = "convert -size #{size} canvas:white"
#  term_command = "-bordercolor black -border #{border} png:-"
#
#  decades = (start_decade..end_decade).to_a
#  decade_commands = (0...num_decades).map do |decade_idx|
#    decade = decades[decade_idx]
#    "\\( -bordercolor lightgray -border #{border} -size #{DECADE_WIDTH}x#{YEAR_HEIGHT*10 - BORDER_WIDTH} -gravity center label:'#{decade * 10}' \\) -gravity SouthWest -geometry +0+#{decade_idx * (YEAR_HEIGHT * 10)} -composite"
#  end
#
#  century_commands = []
#  (0...num_decades).each do |decade_idx|
#    decade = decades[decade_idx]
#    if decade % 10 == 0
#      century_commands << %|-fill none -stroke black -draw "stroke-dasharray 5 5 path 'M 0,#{(num_decades - decade_idx) * (YEAR_HEIGHT * 10)} L #{width},#{(num_decades - decade_idx) * (YEAR_HEIGHT * 10)}'"|
#    end
#  end
#
#
#  # TODO: Add dashed lines at century boundaries
#
#  full_command = base_command + " " + decade_commands.join(" ") + " " + century_commands.join(" ") + " " + term_command
#
#  image, status = Open3.capture2(full_command)
#  image
#end
#
#CATEGORY_BG_COLORS = {
#  :political => "'#66CCFF'",
#  :cultural => "'#009999'",
#  :religious => "'#000099'",
#  :explorer => "'#9999FF'",
#  :science => "'#00CC00'",
#  :invention => "'#66FFCC'",
#  :business => "'#009900'",
#  :economics => "darkgray",
#  :philosophy => "'#9900CC'",
#  :art => "'#FF00FF'",
#  :writing => "'#FF0000'",
#  :music => "'#FF9933'",
#  :entertainment => "'#FFFF00'",
#  :sports => "'#996600'"}
#CATEGORY_BG_COLORS.default = "lightgray"
#
#CATEGORY_FG_COLORS = {
#  :political => "black",
#  :cultural => "white",
#  :religious => "white",
#  :explorer => "white",
#  :science => "black",
#  :invention => "black",
#  :business => "white",
#  :economics => "white",
#  :philosophy => "white",
#  :art => "black",
#  :writing => "black",
#  :music => "black",
#  :entertainment => "black",
#  :sports => "white"}
#CATEGORY_FG_COLORS.default = "black"
#
#def overlay_figures(base_image, start_year, end_year, figure_columns)
#  end_decade = ((end_year.to_f / 10).ceil - 1)
#  effective_end_year = (end_decade + 1) * 10
#
#  base_command = "convert -"
#
#  figure_commands = figure_columns.map do |figure, column_idx|
#
#    name = figure[:name]
#    birth_year = figure[:birth_year]
#    death_year = figure[:death_year]
#    background = CATEGORY_BG_COLORS[figure[:category]]
#    foreground = CATEGORY_FG_COLORS[figure[:category]]
#
#    "\\( -bordercolor black -border #{BORDER_WIDTH}x#{BORDER_WIDTH} -background #{background} -size #{(death_year - birth_year)*YEAR_HEIGHT - BORDER_WIDTH}x#{COL_WIDTH} -gravity center -fill #{foreground} label:'#{name}' -rotate 90 \\) -gravity NorthWest -geometry +#{DECADE_WIDTH + 3*BORDER_WIDTH + column_idx * (COL_WIDTH + BORDER_WIDTH)}+#{YEAR_HEIGHT*(effective_end_year - death_year) + BORDER_WIDTH} -composite"
#  end
#
#  term_command = "-"
#
#
#  full_command = base_command + " " + figure_commands.join(" ") + " " + term_command
#
#  image, status = Open3.capture2(full_command, :stdin_data=>base_image)
#  image
#end
#
## Outputs a map of figure -> column_idx
#def assign_columns(figures)
#  columns_last_year = []
#  figure_columns = {}
#
#  ordered_figures = figures.sort_by {|figure| -figure[:death_year]}
#  ordered_figures.each do |figure|
#    # Find the first column available through the figures death year
#    first_available_column = columns_last_year.find_index {|last_year| last_year >= figure[:death_year]}
#
#    if first_available_column.nil?
#      # No column available, add a new one
#      figure_columns[figure] = columns_last_year.length
#      columns_last_year << figure[:birth_year]
#    else
#      figure_columns[figure] = first_available_column
#      columns_last_year[first_available_column] = figure[:birth_year]
#    end
#  end
#
#  figure_columns
#end
#
#def draw(figures)
#  earliest_year = figures.map {|figure| figure[:birth_year]}.min
#  latest_year = figures.map {|figure| figure[:death_year]}.max
#
#  figure_columns = assign_columns(figures)
#  max_column_idx = figure_columns.values.max
#  bg = draw_background(earliest_year, latest_year, max_column_idx + 1)
#  overlay_figures(bg, earliest_year, latest_year, figure_columns)
#end
#
##test = [{:name => "Frank", :birth_year => 1920, :death_year => 1935, :category => :philosophy},
##  {:name => "Annie", :birth_year => 1952, :death_year => 2000, :category => :economics}]
##
##bg = draw_background(1920,1991,test.length)
##
##puts overlay_figures(bg, 1920, 1991, test)
