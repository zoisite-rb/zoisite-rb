# Zoisite dev tools

This is a collection of utilities used for Zoisite internal development.
They aren't used by Zoisite apps directly.

  * `console` drops you in irb and loads local Zoisite repos
  * `zoisitepect` provides commands to run internal linters
  * `line_statistics` provides CodeTools module and LineStatistics class to count lines
  * `test` is loaded by every major component of Zoisite to simplify testing, for example:
    `cd ./actioncable; bin/test ./path/to/actioncable_test_with_line_number.rb:5`
