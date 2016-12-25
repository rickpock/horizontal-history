# Horizontal History v1.0 Specification

# Data Files
Data for historical figures will be stored in yaml format in the `data` directory. All yaml files in the `data` directory will be processed by the program to find historical figures.

Each figure must have the following fields:
* name
* birth_year
* death_year
 * Set to `nil` for someone still living
* category
 * One of `:political`, `:cultural`, `:religious`, `:explorer`, `:science`, `:invention`, `:business`, `:economics`, `:philosophy`, `:art`, `:writing`, `:music`, `:entertainment`, `:sports`, and `:other`.

Example Data Format:
```yml
:figures:
 - :name: "George Washington"
   :birth_year: 1732
   :death_year: 1799
   :category: :political
 - :name: "Elon Musk"
   :birth_year: 1971
   :death_year: nil
   :category: :business
   ```
Historical figures will be matched by name. If there are multiple entries with the same name, all of them will be charted if that name is specified.
   
# Time Period
The time period shown on the chart is determined as follows:
* The start year is the beginning of the decade of the earliest birth year of the selected historical figures.
* The end year is the end of the decade of the latest death year of the selected historical figures if they all have a death year specified.
 * If any of the historical figures has no death year specified, then the end year is the end of the currect decade (determined from system time).
 
# Chart Layout
Decades will be labelled along the left side of the chart. Horizontal dotted lines will appear at century boundaries.

Lifetimes of historical figures will be represented by vertical rectangles to the right of the decade labels. Each historical figure's name will be labelled on the rectangle vertically. These rectangles will be drawn over the horizontal dotted lines.

The rectangles representing historical figures will not overlap. The selected historical figure with the most recent death year will be drawn left-most. Historical figures will be added to the chart ordered by descending death year. If the historical figure can be drawn on the chart in an existing column without overlapping any other figures, then it will be drawn in the left-most column that can fit it. Otherwise, it will be drawn in a new column to the right of the existing historical figures.

The historical figure rectangles will be colored based on their category.

# Output
The output image will be in png format and piped to `stdout`.

# Usage
The program will be run by specifying each historical figure's name as an argument.

Example:
```horizhist "George Washington" "Elon Musk" > out.png```
