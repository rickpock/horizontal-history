#
# Drawing constants
#

COL_WIDTH = 30
DECADE_WIDTH = 60
BORDER_WIDTH = 1
YEAR_HEIGHT = 3

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

#
# Helper methods
#

def get_decades(start_year, end_year)
  start_decade = (start_year.to_f / 10).floor
  end_decade = ((end_year.to_f / 10).ceil - 1)

  (start_decade..end_decade).to_a
end

def get_canvas_size(start_year, end_year, num_cols)
  decades = get_decades(start_year, end_year)

  width = DECADE_WIDTH + num_cols * (COL_WIDTH)
  height = (YEAR_HEIGHT * 10) * decades.length

  return width*3, height
end

#
# Drawing methods
#

def draw_background(dp, start_year, end_year, num_cols)
  width, height = get_canvas_size(start_year, end_year, num_cols)

  # Set a border around the canvas
  dp.set_border(BORDER_WIDTH, 'black')

  # Draw decade labels
  decades = get_decades(start_year, end_year)
  (0...(decades).length).each do |decade_idx|
    decade = decades[decade_idx]

    text_position = {
      :x => 0, :y => decade_idx * (YEAR_HEIGHT * 10),
      :x_align => :left, :y_align => :bottom,
      :width => DECADE_WIDTH, :height => (YEAR_HEIGHT * 10),
    }
    text_settings = {
      :text_x_align => :middle, :text_y_align => :center,
      :border_thickness => 1, :border_color => 'lightgray',
    }
    dp.draw_text(text_position, "#{decade * 10}", text_settings)
  end

  # Draw century dividers
  (0...(decades).length).each do |decade_idx|
    decade = decades[decade_idx]
    next if decade % 10 != 0

    y = (decades.length - decade_idx) * (YEAR_HEIGHT * 10)
    path = [
      {
        :type => :start,
        :x => 0, :y => y,
      },
      {
        :type => :line,
        :x => DECADE_WIDTH, :y => y,
      }]
    dp.draw_path(path, {:color => 'black', :dash_pattern => [5,5]})
  end
end

# Draw historical figure life bars over the background
def overlay_figures(dp, start_year, end_year, figure_columns)
  end_decade = ((end_year.to_f / 10).ceil - 1)
  effective_end_year = (end_decade + 1) * 10

  figure_commands = figure_columns.map do |figure, column_idx|

    name = figure[:name]
    birth_year = figure[:birth_year]
    death_year = figure[:death_year]
    background = CATEGORY_BG_COLORS[figure[:category]]
    foreground = CATEGORY_FG_COLORS[figure[:category]]

    x = DECADE_WIDTH + column_idx * COL_WIDTH
    y = YEAR_HEIGHT * (effective_end_year - death_year)
    height = COL_WIDTH
    width = (death_year - birth_year) * YEAR_HEIGHT
    text_position = {
      :x => x, :y => y,
      :height => height, :width => width,
    }
    text_settings = {
      :text_x_align => :middle, :text_y_align => :center,
      :border_thickness => BORDER_WIDTH, :border_color => 'black',
      :bg_color => background, :color => foreground}

    dp.draw_text(text_position, name, text_settings, {:rotate => 90, :rotate_origin => [x + height/2, y + height/2]})
  end
end

#
# Layout methods
#

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

#
# Main method
#

def draw(provider_name, figures)
  # Determine image size
  start_year = figures.map {|figure| figure[:birth_year]}.min
  end_year = figures.map {|figure| figure[:death_year]}.max

  figure_columns = assign_columns(figures)
  max_column_idx = figure_columns.values.max

  num_decades = get_decades(start_year, end_year).length

  num_cols = max_column_idx + 1
  width = DECADE_WIDTH + num_cols * COL_WIDTH
  height = (YEAR_HEIGHT * 10) * num_decades

  # Initialize the Drawing Provider
  dp = Object.const_get(provider_name).new(width, height, 'white')

  # Draw the background
  draw_background(dp, start_year, end_year, num_cols)

  # Draw the figures
  overlay_figures(dp, start_year, end_year, figure_columns)

  # Draw grayed-out area for the future
  current_year = Time.now.year
  end_decade = ((end_year.to_f / 10).ceil - 1)
  effective_end_year = (end_decade + 1) * 10

  dp.draw_rectangle(DECADE_WIDTH, 0,
                    width, (effective_end_year - current_year) * YEAR_HEIGHT,
                    {:color => 'gray'}, # stroke modifiers
                    {:color => 'gray'}) # fill modifiers
  
  # Build the final image
  puts dp.build
end
