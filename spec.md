# Horizontal History v1.0 Specification

# Data Files
Data for historical figures will be stored in yaml format in the `data` directory. All yaml files in the `data` directory will be processed by the program to find historical figures.

Each figure must have the following fields:
* name
* birth-year
* death-year
 * Set to `nil` for someone still living
* category
 * One of `:political`, `:cultural`, `:religious`, `:explorer`, `:science`, `:invention`, `:business`, `:economics`, `:philosophy`, `:art`, `:writing`, `:music`, `:entertainment`, `:sports`, and `:other`.

Example Data Format:
```yml
:figures:
 - :name: "George Washington"
   :birth-year: 1732
   :death-year: 1799
   :category: :political
 - :name: "Elon Musk"
   :birth-year: 1971
   :death-year: nil
   :category: :business
   ```
