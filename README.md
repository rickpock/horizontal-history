# horizontal-history
A history visualization tool charting the lifetimes of historical figures.

# What is it?
This project is inspired by Tim Urban's ["Horizontal History" article](http://waitbutwhy.com/2016/01/horizontal-history.html).

The project generates images charting the lifetimes of historical figures.

# Supported Platforms
Only OS X.

It may work on additional platforms, but I've only developed and tested it on OS X so far.

# Prerequisities
* [Ruby](https://www.ruby-lang.org/en/documentation/installation/) runtime 2.3.0+
* Open3 Ruby gem
* [ImageMagick](https://www.imagemagick.org/script/binary-releases.php)
 - For OS X, installed via [homebrew](http://brew.sh/) using `brew install imagemagick`.

# Usage
`ruby src/horizhist [args] >[image_file]`
`args` can be a list of names of historical figures or categories of historical figures or both. See the [spec](https://github.com/rickpock/horizontal-history/blob/master/spec.md) for details.

The program outputs the png image data to stdout. Redirect the stream to the filename of your choice.

# Version 1.0 Spec
[Spec](https://github.com/rickpock/horizontal-history/blob/master/spec.md)

# Legal Stuff
This project is licensed under the MIT License. Check the LICENSE file for details.

All code is copyrighted by Rick Pocklington.
