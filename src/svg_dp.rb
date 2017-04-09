require 'nokogiri'

# SVG Drawing Provider
class SvgDP
private
  # Parameters specifying all of the drawing primitives
  @drawing_command = ""

  # Properties of the canvas
  @doc = nil

  @width = 0
  @height = 0

  UNITS = "mm"

  DEFAULT_BG_COLOR = 'white'
  DEFAULT_BORDER_COLOR = 'black'

  @bg_color = DEFAULT_BG_COLOR
  @bg_thickness = 1

  # Adds elements as if calling the builder within the 'svg' element
  def add_elements
    Nokogiri::XML::Builder.with(@doc.at('svg')) do |xml|
      yield xml
    end
  end

  def fix_color(color)
    color.nil? ? nil : color.sub(/^'(.*)'$/, '\1')
  end

public
  def initialize(width, height, bg_color = DEFAULT_BG_COLOR)
    @width = width
    @height = height

    builder = Nokogiri::XML::Builder.new do |xml|
      # Root svg element
      svg_attr = {
        'width' => "#{@width}#{UNITS}",
        'height' => "#{@height}#{UNITS}",
        'viewBox' => "0 0 #{@width} #{@height}",
        'xmlns' => 'http://www.w3.org/2000/svg',
        'version' => '1.1',
      }
      xml.svg(svg_attr) do
        fill_attr = {
          'x' => "0", 'y' => "0",
          'width' => "#{@width}", 'height' => "#{@height}",
          'fill' => bg_color,
        }
        xml.rect(fill_attr)
      end
    end

    @doc = builder.doc
  end

  def set_border(thickness, color = DEFAULT_BORDER_COLOR)
    @bg_thickness = thickness
    @bg_color = color

    # Return self to support the builder pattern
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
  # * thickness
  # * dash_pattern (array of draw length, skip length)
  def draw_path(path, stroke = {})
    path_expr = path.map do |point|
      case point[:type]
      when :start, :M, 'M'
        "M #{point[:x]} #{point[:y]}"
      when :line, :L, 'L'
        "L #{point[:x]} #{point[:y]}"
      else
        ""
      end
    end.join(" ")

    add_elements do |xml|
      path_attr = {
        'd' => path_expr,
        'stroke' => (stroke.nil? || stroke[:color].nil?) ? "black" : fix_color(stroke[:color]),
        'fill' => 'none',
      }

      unless stroke.nil? || stroke[:dash_pattern].nil?
        path_attr['stroke-dasharray'] = stroke[:dash_pattern].join(",")
      end
      unless stroke.nil? || stroke[:thickness].nil?
        path_attr['stroke-width'] = stroke[:thickness]
      end

      xml.path(path_attr)
    end

    # Return self to support the builder pattern
    self
  end

  # stroke (same as stroke on draw_path)
  #
  # fill:
  # * color
  def draw_rectangle(x1, y1, x2, y2, stroke = {}, fill = {})
    style_arry = []
    unless stroke.nil? || stroke[:dash_pattern].nil?
      style_arry << "stroke-dasharray:#{stroke[:dash_pattern].join(",")}"
    end
    style_arry << "stroke:#{(stroke.nil? || stroke[:color].nil?) ? "black" : fix_color(stroke[:color])}"
    style_arry << "fill:#{(fill.nil? || fill[:color].nil?) ? "none" : fix_color(fill[:color])}"
    unless stroke.nil? || stroke[:thickness].nil?
      style_arry << "stroke-width:#{stroke[:thickness]}"
    end

    add_elements do |xml|
      rect_attr = {
        'x' => "#{x1}", 'y' => "#{y1}",
        'width' => "#{x2-x1}", 'height' => "#{y2-y1}",
        'style' => style_arry.join(';'),
      }

      xml.rect(rect_attr)
    end

    # Return self to support the builder pattern
    self
  end

  # Handle edge cases of x_align or y_align not being defined.
  def effective_x_align(x_align, y_align)
    case x_align
    when :left, :middle, :right
      x_align
    else
      # Default horizontal alignment depends on vertical alignment
      # If vertical alignment is set to top or bottom, we assume it should be centered at top/bottom
      case y_align
      when :top, :bottom
        :middle
      else
        :left
      end
    end
  end

  # Handle edge cases of x_align or y_align not being defined.
  def effective_y_align(x_align, y_align)
    case y_align
    when :top, :center, :bottom
      y_align
    else
      # Default vertical alignment depends on horizontal alignment
      # If horizontal alignment is set to left or right, we assume it should be centered at left/right
      case x_align
      when :left, :right
        :center
      else
        :top
      end
    end
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
  #
  # transform:
  # * matrix
  # * rotate
  # * scale (currently unsupported)
  # * translate (currently unsupported)
  def draw_text(position, text, settings = {}, transform = {})
    # TODO: Apply transform

    # The text alignment is relative to a single point, rather than a rectangle.
    # What point should be used depends on the text alignment.
    # For example, if we want the text aligned right, the x value should be the right of the text.
    x_offset =
      case effective_x_align(settings[:text_x_align], settings[:text_y_align])
      when :left
        0
      when :middle
        position[:width] / 2.0
      when :right
        position[:width]
      end

    y_offset =
      case effective_y_align(settings[:text_x_align], settings[:text_y_align])
      when :top
        0
      when :center
        position[:height] / 2.0
      when :bottom
        position[:height]
      end

    # Now we tranform into coordinates relative to the top-left corner since SVG
    # doesn't provide a way to specify coordinate relative to any other position.
    # An actual transform cannot be used for this, since that would transform everything being drawn, including
    # the text itself, instead of just the position.
    left_x =
      case effective_x_align(position[:x_align], position[:y_align])
      when :left
        position[:x]
      when :middle
        position[:x] + (@width / 2.0) - (position[:width] / 2.0)
      when :right
        @width - position[:x] - position[:width]
      end

    top_y =
      case effective_y_align(position[:x_align], position[:y_align])
      when :top
        position[:y]
      when :center
        position[:y] + (@height / 2.0) - (position[:height] / 2.0)
      when :bottom
        @height - position[:y] - position[:height]
      end

    # SVG doesn't support fill options for the text background, so we'll draw
    # a rectangle as the background
    unless settings[:bg_color].nil? && settings[:border_thickness].nil?
      draw_rectangle(
        left_x, top_y,
        left_x + position[:width], top_y + position[:height],
        {:thickness => settings[:border_thickness], :color => settings[:border_color]},
        {:color => settings[:bg_color]}
      )
    end

    add_elements do |xml|
      text_attr = {
        'x' => left_x + x_offset, 'y' => top_y + y_offset,
      }
      unless settings[:text_x_align].nil?
        text_attr["text-anchor"] =
          case settings[:text_x_align]
          when :left
            "start"
          when :middle
            "middle"
          when :right
            "end"
          else
            "start"
          end
      end
      unless settings[:text_y_align].nil?
        text_attr["alignment-baseline"] =
          case settings[:text_y_align]
          when :top
            "hanging"
          when :center
            "central"
          when :bottom
            "baseline"
          else
            "hanging"
          end
      end

      xml.text_(text_attr) { xml.text text }
    end


    # Return self to support the builder pattern
    self
  end

  def build()
    # Border rectangle
    add_elements do |xml|
      border_attr = {
        'x' => "0", 'y' => "0",
        'width' => "#{@width}", 'height' => "#{@height}",
        'stroke' => @bg_color, 'stroke-width' => "#{@bg_thickness}",
        'fill' => 'none',
      }
      xml.rect(border_attr);
    end

    @doc.to_s
  end
end
