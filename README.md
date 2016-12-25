# horizontal-history
A history visualization tool charting the lifetimes of historical figures.

# What is it?
This project is inspired by Tim Urban's ["Horizontal History" article](http://waitbutwhy.com/2016/01/horizontal-history.html)

The project generates images charting the lifetimes of historical figures.

# Supported Platforms
Only OS X.

# Prerequisities
* Ruby runtime
* Open3 gem
* ImageMagick

TODO: Provide installation instructions for these prerequisites.

# Usage
`ruby src/horizhist [args] >[image_file]`
`args` can be a list of names of historical figures or categories of historical figures or both. See the [spec](https://github.com/rickpock/horizontal-history/blob/master/spec.md) for details.

The program outputs the png image data to stdout. Redirect the stream to the filename of your choice.

# Version 1.0 Spec
[Spec](https://github.com/rickpock/horizontal-history/blob/master/spec.md)

# Legal Stuff
This project is licensed under the MIT License. Check the LICENSE file for details.

All code is copyrighted by Rick Pocklington.
