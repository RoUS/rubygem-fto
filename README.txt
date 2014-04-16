FTO -- Formatted Textual Output
===============================

* http://rubyforge.org/projects/fto/

DESCRIPTION:
------------

FTO is a Ruby library for formatting text strings.  In function it is
similar to printf(3); however, the syntax of the format effectors
(sometimes called 'format descriptors') and the selection of effectors
bundled with the package are based on the SYS$FAO user-mode system
service found on OpenVMS.


FEATURES:
---------

* Feature-rich set of formatting directives (called 'effectors')
  provided as a standard part of the library.

* Developers can add their own directives, even completely replacing
  the standard set with others that use a different syntax.


PROBLEMS:
---------

* Multi-byte character sets are not yet supported.


SYNOPSIS:
---------

  require 'fto'
  include FormatText
  formatString = FTO.new("This will include a string: !AS", "string1")
  puts formatString.format
  puts formatString.format("string2")

The classes are contained in the FormatText module in order to
avoid any name collisions (such as the Context class might cause,
for instance).


REQUIREMENTS:
-------------

Nothing special.


INSTALL:
--------

FTO is installed using the canonical method:

  sudo gem install fto


LICENSE:
--------

Copyright 2009 Ken Coar

Licensed under the Apache License, Version 2.0 (the "License"); you
may not use this file except in compliance with the License. You may
obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied. See the License for the specific language governing
permissions and limitations under the License.
