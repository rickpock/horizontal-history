require 'RMagick'

# PNG Drawing Provider
class PngDP
private
  @svg_dp

  DEFAULT_BG_COLOR = 'white'
  DEFAULT_BORDER_COLOR = 'black'

public
  def initialize(width, height, bg_color = DEFAULT_BG_COLOR)
    @svg_dp = SvgDP.new(width, height, bg_color)
  end

  def set_border(thickness, color = DEFAULT_BORDER_COLOR)
    @svg_dp.set_border(thickness, color)

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
    @svg_dp.draw_path(path, stroke)

    # Return self to support the builder pattern
    self
  end

  # stroke (same as stroke on draw_path)
  #
  # fill:
  # * color
  def draw_rectangle(x1, y1, x2, y2, stroke = {}, fill = {})
    @svg_dp.draw_rectangle(x1, y1, x2, y2, stroke, fill)

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
    @svg_dp.draw_text(position, text, settings, transform)

    # Return self to support the builder pattern
    self
  end

  def build()
    svg_xml = @svg_dp.build()
    png_img = Magick::Image.from_blob(svg_xml) { format = 'SVG' }[0]

    # The format must be set on the Image object, rather than passed in to the `to_blob` method.
    # See RMagick issue #14: https://github.com/rmagick-temp/rmagick/issues/14
    png_img.format = 'PNG'
    png_img.to_blob
  end
end
