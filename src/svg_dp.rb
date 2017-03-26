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

  # Adds elements as if calling the builder within the 'svg' element
  def add_elements
    Nokogiri::XML::Builder.with(@doc.at('svg')) do |xml|
      yield xml
    end
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
        'xmlns' => 'http://www.w3.org/2000/svg',
        'version' => '1.1',
      }
      xml.svg(svg_attr) do
        fill_attr = {
          'x' => "0#{UNITS}", 'y' => "0#{UNITS}",
          'width' => "#{@width}#{UNITS}", 'height' => "#{@height}#{UNITS}",
          'fill' => bg_color,
        }
        xml.rect(fill_attr)
      end
    end

    @doc = builder.doc
  end

  def set_border(thickness, color = DEFAULT_BORDER_COLOR)
    # Border rectangle
    add_elements do |xml|
      border_attr = {
        'x' => "0#{UNITS}", 'y' => "0#{UNITS}",
        'width' => "#{@width}#{UNITS}", 'height' => "#{@height}#{UNITS}",
        'stroke' => color, 'stroke-width' => "#{thickness}#{UNITS}",
        'fill' => 'none',
      }
      xml.rect(border_attr);
    end

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
  # * dash_pattern (array of draw length, skip length)
  def draw_path(path, stroke = {})
    # TODO

    # Return self to support the builder pattern
    self
  end

  # stroke (same as stroke on draw_path)
  #
  # fill:
  # * color
  def draw_rectangle(x1, y1, x2, y2, stroke = {}, fill = {})
    # TODO

    # Return self to support the builder pattern
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
  #
  # transform:
  # * matrix
  # * rotate
  # * scale (currently unsupported)
  # * translate (currently unsupported)
  def draw_text(position, text, settings = {}, transform = {})
    # TODO

    # Return self to support the builder pattern
    self
  end

  def build()
    @doc.to_s
  end
end
