require 'yaml'

def load_data(dir)
  figures = []
  current_year = Time.now.year
  Dir.glob(File.join(dir, "*.yml")) do |data_file|
    figures = figures + YAML.load(File.read(data_file))[:figures].each do |figure|
      figure[:death_year] = figure[:death_year] || current_year
    end
  end
  figures
end

FIGURES = load_data("data")

def find_figures(figure_names, figure_categories)
  FIGURES.select do |figure|
    figure_names.include?(figure[:name]) || figure_categories.include?(figure[:category])
  end
end
