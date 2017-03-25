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

  # path is an array of hashes of points and how the path is connected to that point:
  # * type
  # ** :start or :M or M
  # ** :line or :L or L
  # * x
  # * y
  #
  # stroke:
  # * color
  # * dash_pattern (array of draw length, skip length)
  def draw_path(path, stroke = {})
    path_expr = path.map do |point|
      case point[:type]
      when :start, :M, 'M'
        "M #{point[:x]},#{point[:y]}"
      when :line, :L, 'L'
        "L #{point[:x]},#{point[:y]}"
      else
        ""
      end
    end.join(" ")

    dash_expr = (stroke.nil? || stroke[:dash_pattern].nil?) ? "" : "stroke-dasharray #{stroke[:dash_pattern].join(" ")} "

    stroke_color = (stroke.nil? || stroke[:color].nil?) ? "black" : stroke[:color]

    draw_command = %|-fill none -stroke #{stroke_color} -draw "#{dash_expr}path '#{path_expr}'"|

    @drawing_command = "#{@drawing_command}#{draw_command} "
  end
#  century_commands = []
#  (0...num_decades).each do |decade_idx|
#    decade = decades[decade_idx]
#    if decade % 10 == 0
#      century_commands << %|-fill none -stroke black -draw "stroke-dasharray 5 5 path 'M 0,#{(num_decades - decade_idx) * (YEAR_HEIGHT * 10)} L #{width},#{(num_decades - decade_idx) * (YEAR_HEIGHT * 10)}'"|
#    end
#  end

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
  #
  # transform:
  # * matrix
  # * rotate
  # * scale (currently unsupported)
  # * translate (currently unsupported)
  def draw_text(position, text, settings = {}, transform = {})
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

    color = settings[:color]
    color_expr = color.nil? ? "" : "-fill #{color} "

    bg_color = settings[:bg_color]
    bg_expr = bg_color.nil? ? "" : "-background #{bg_color} "

    # Extract parameters from `transform`
    transform_expr = if transform.nil? || transform.empty?
                       ""
                     elsif ! transform[:matrix].nil?
                       "-affine #{transform[:matrix].join(',')} -transform "
                     elsif ! transform[:rotate].nil?
                       "-rotate #{transform[:rotate]} "
                     else # TODO: Support scale and translate transforms?
                       ""
                     end

    # Build command for drawing
    text_command = "\\( #{border_expr}#{bg_expr}#{color_expr}#{size_expr}-stroke none -gravity #{text_gravity} label:'#{text}' #{transform_expr}\\) -gravity #{pos_gravity} -geometry +#{x}+#{y} -composite"
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
