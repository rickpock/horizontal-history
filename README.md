# horizontal-history
A history visualization tool charting the lifetimes of historical figures.

# What is it?
This project is inspired by Tim Urban's ["Horizontal History" article](http://waitbutwhy.com/2016/01/horizontal-history.html).

The project generates images charting the lifetimes of historical figures.

# Supported Platforms
This should work on any platform

It has specifically been tested on OS X, with images svg images rendered using Chrome.

# Prerequisities
* [Ruby](https://www.ruby-lang.org/en/documentation/installation/) runtime 2.3.0+
* For PNG output:
  - [ImageMagick](https://www.imagemagick.org/script/binary-releases.php)
    - For OS X, installed via [homebrew](http://brew.sh/) using `brew install imagemagick`.
  - RMagick gem (installed via `bundle`)

# Usage
`ruby src/horizhist [args] [format] >[image_file]`
`args` can be a list of names of historical figures or categories of historical figures or both. `format` can be `-svg` or `-png`. See the [spec](https://github.com/rickpock/horizontal-history/blob/master/spec.md) for details.

The program outputs the png image data to stdout. Redirect the stream to the filename of your choice.

## Example
`ruby src/horizhist.rb "Nelson Mandela" :business > doc/example-output.svg`

![](https://raw.githubusercontent.com/rickpock/horizontal-history/master/doc/example-output.png)

# Version 1.0 Spec
[Spec](https://github.com/rickpock/horizontal-history/blob/master/spec.md)

# Version 2.0 Spec
[Spec](https://github.com/rickpock/horizontal-history/blob/master/spec2.md)

# Legal Stuff
This project is licensed under the MIT License. Check the [LICENSE file](https://raw.githubusercontent.com/rickpock/horizontal-history/master/LICENSE) for details.

All code is copyrighted by Rick Pocklington.

# Contributing
Additional contributors to the project are welcome!

But I don't understand how github project user management works, so if you're interested in contributing, email me at rickpock at gmail.com.
