#--
# Copyright © 2009,2022 Ken Coar
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License.  You
# may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.
#++
# frozen_string_literal: true

require('rubygems')
require('bundler')
Bundler.setup
require('byebug')
require_relative('fto/version')
require_relative('fto/classmethods')

# @private
#
# Stuff from `SYS$FAO` that isn't yet implemented (and may not be
# reasonable outside of OpenVMS).  Or that SYS$FAO lacks altogether,
# but `printf(3)` <em>does</em> have.
#
# @todo
#  ![n[.[n]]]F for floating point
#
# @todo
#  !n%C Inserts a character string when the most recently
#        evaluated argument has the value n. (Recommended for use
#        with multilingual products.)
# @todo
#  !%E Inserts a character string when the value of the most
#        recently evaluated argument does not match any preceding
#        !n%C directives. (Recommended for use with multilingual
#        products.)
# @todo
#  !%F 	Makes the end of a plurals statement.
#
# Other things..
#
# @todo
#  Idempotency (not the right term..) -- run idempotent effectors
#  first?
#

module FTO

  #
  def self.new(*args)
    
  end                           # def self.new(*args)
    
  nil
end                            # module FTO
#
# = fto.rb - Formatted Text Output
#
# Author::    Ken Coar
# Copyright:: Copyright © 2009 Ken Coar
# License::   Apache Licence 2.0
#
# == Synopsis
#
#   require 'fto'
#   include FormatText
#   formatString = FTO.new("This will include a string: !AS", "string1")
#   puts formatString.format
#   puts formatString.format("string2")
#
# == Description
#
# FTO is a Ruby library for formatting text strings.  In function it
# is similar to <tt>printf(3)</tt>; however, the syntax of the format
# effectors (sometimes called 'format descriptors') and the selection
# of effectors bundled with the package are based on the `SYS$FAO`
# user-mode system service found on OpenVMS.
#
# The FTO class is an extension of String, enhancing the constructor,
# adding the #format instance method, and the
# #registerEffector class method.
#
# In addition to the included list of effectors, FTO provides easy
# extensibility by allowing the developer to write hir own effector
# handlers and registering them with
# FormatText::FTO.registerEffector()</i>.
#
#--
# Copyright 2009 Ken Coar
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License. You may
# obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied. See the License for the specific language governing
# permissions and limitations under the License.
#++


#--
# Notes about markup (docco being hard to find).  This will be deleted
# ere long.
#
# \:arg:, \:args:
#
# \:call-seq:
#    Alternative(s) to default invocation built by rdoc
#
# \:doc:
#
# \:enddoc:
#    Stop documenting the current tree of items
#
# \:include:
#    Pull in another file.
#
# \:main:
#
# \:nodoc: all
#
# \:nodoc:
#    Temporarily turn off rdoc interpretation
#
# \:notnew:, \:not_new:, \:not-new:
#    Document constructor as 'initialize' rather than as 'new'
#
# \:section:
#
# \:title:
#    Duh.
#
# \:yield:, \:yields:
#    Display an alternative to the automatic 'yields' rdoc makes up
#
# Stuff from SYS$FAO that isn't yet implemented (and may not be
# reasonable outside of OpenVMS).  Or that SYS$FAO lacks altogether.
#
# @todo
#  ![n[.[n]]]F for floating point
# @todo
#  !n%C Inserts a character string when the most recently
#        evaluated argument has the value n. (Recommended for use
#        with multilingual products.)
# @todo
#  !%E Inserts a character string when the value of the most
#        recently evaluated argument does not match any preceding
#        !n%C directives. (Recommended for use with multilingual
#        products.)
# @todo
#  !%F 	Makes the end of a plurals statement.
#
# Other things..
#
# @todo
#   Idempotency (not the right term..) -- run idempotent effectors first?
#++

require 'rubygems'
require 'gettext'
require 'versionomy'

module FormatText

  Version = Versionomy.parse('1.0.2')
  VERSION = Version.to_s

  include(GetText)

  #
  # Each time an effector's pattern is matched, its _code_ attribute
  # is called with this structure, which is used to communicate
  # details to the code block, and by the code block to pass back some
  # behaviour modification notes.  Most of the attributes should be
  # treated as read-only, with exceptions noted below in the attribute
  # descriptions.
  #
  # This class is used internally by the +fto+ library and isn't
  # really intended for external consumption.
  #
  class Context

    #
    # <i>FormatText::Effector</i>.  The _Effector_ object
    # involved.  Read-only.
    #
    attr_accessor  :effectorObj

    #
    # <i>FormatText::FTO</i>.  The _FTO_ object being processed.
    # Read-only.
    #
    attr_accessor  :ftoObj

    #
    # _String_.  The string that matched the effector and triggered
    # its processing.  Read-only.
    #
    attr_accessor  :sMatched

    #
    # _Array_.  Arguments remaining to be processed.  Usually
    # read-only, but see the description of the _usedArgs_ attribute
    # for exceptions.  Accessed with <i>getArgument()</i> and modified with
    # <i>shiftArgument()</i> and <i>unshiftArgument()</i>.
    #
    attr_accessor  :usedArgs

    #
    # _Array_.  List of arguments already processed.  Usually
    # read-only.  The effector function is responsible for using the
    # values in this array to perform its task.
    #
    # The only time this should be considered read/write is when the
    # effector is intended to modify the list of arguments being used
    # to build the final string.  The _argList_ attribute should be
    # modified in conjunction with _usedArgs_ to maintain continuity.
    # By default, after the effector function returns, the caller (the
    # <i>FormatText::FTO#format()</i> method) will take the element
    # from the front of the _argList_ array and push it onto the end of the
    # _usedArgs_ array.
    #
    attr_accessor  :argList

    #
    # _Any_.  The <i>FormatText::FTO#format()</i> sets this to the last argument
    # that was actually used.
    #
    attr_accessor :lastArgUsed

    #
    # _Boolean_.  The effector function sets this to +true+ to inhibit
    # the <i>FormatText::FTO#format()</i> method from modifying the
    # argument list after the function returns.  See the descriptions under the
    # _argList_ and _usedArgs_ attributes.
    #
    attr_accessor  :reuseArg

    #
    # === Description
    # Create a new <i>FormatText::Context</i> object.  There may only
    # be a single argument to the constructor, and it must be a hash,
    # using symbols for the names of the attributes to set:
    #
    #    x = FormatText::Context.new({ :sMatched => 'string', :reuseArg => false })
    #
    # This class is used internally by the +fto+ library and isn't
    # really intended for external consumption.
    #
    # :call-seq:
    # new<i>(sHash)</i> => <i>FormatText::Context</i>
    #
    # === Arguments
    # [_sHash_] <i>Hash</i>.  A hash with symbolic keys corresponding to the attribute names.
    #
    # === Exceptions
    # [<tt>RuntimeError</tt>] If passed anything other than a <i>Hash</i>.
    #
    def initialize(*argsp)
      (@effectorObj, @ftoObj) = nil
      @sMatched = ''
      @usedArgs = []
      @argList = []
      @reuseArg = false
      if (argsp[0].class != Hash)
        raise RuntimeError, self.class.name + _(' requires a Hash to create')
      end
      argsp[0].each { |key,val| eval("self.#{key.to_s} = val") }
    end                         # def initialize

    #
    # === Description
    # Get the next argument from the _Context_ object, use the default,
    # or raise an exception.
    #
    # :call-seq:
    # getArgument<i>()</i> => <i>any</i>
    #
    # === Exceptions
    # [<tt>RuntimeError</tt>] If there is no argument to fetch and the effector does not specify a default value.
    #
    def getArgument()
      unless (@argList.empty?)
        return @argList.first
      end
      if ((arg = eContext.effectorObj.dValue).nil?)
        raise RuntimeError,
          _('Insufficient arguments to format ') + "'#{@ftoObj}'"
      end
      arg
    end                         # def getArgument()

    #
    # === Description
    # Moves the specified number of arguments (default is 1) from the
    # 'arguments pending' array (<i>argList</i>) to the 'arguments consumed'
    # array (<i>usedArgs</i>).  If there are fewer pending arguments
    # than are specified, only those actually pending are moved.
    #
    # :call-seq:
    # shiftArgument<i>()</i> => <i>any</i>
    # shiftArgument<i>(nArgs)</i> => <i>any</i>
    #
    # === Arguments
    # [<i>nArgs</i>] <i>Fixnum</i>.  Number of arguments to move to the 'already used' array.  Default is 1.
    # If <i>nArgs</i> is negative, values will be popped off the end of the
    # <i>usedArgs</i> array and put back on the front of the <i>argList</i>
    # array.
    #
    # === Returns
    # <i>Any</i>.  The last value in the <i>usedArgs</i> array after the
    # move.
    #
    def shiftArgument(n=1)
      if (n >= 0)
        n.times do |i|
          @usedArgs.push(@argList.shift) unless (@argList.empty?)
        end
      else
        n.abs.times do |i|
          @argList.unshift(@usedArgs.pop) unless (@usedArgs.empty?)
        end
      end
      @usedArgs.last
    end                         # def shiftArgument

    #
    # === Description
    # Moves the specified number of arguments (default is 1) from the
    # 'arguments consumed' array (<i>usedArgs</i>) to the 'arguments pending'
    # array (<i>argList</i>).  If there are fewer already-consumed arguments
    # than are specified, only those actually in the <i>usedArgs</i>
    # array are moved.
    #
    # :call-seq:
    # unshiftArgument<i>()</i> => <i>any</i>
    # unshiftArgument<i>(nArgs)</i> => <i>any</i>
    #
    # === Arguments
    # [<i>nArgs</i>] <i>Fixnum</i>.  Number of already-used arguments to move to the 'arguments pending' array.  Default is 1.
    # If <i>nArgs</i> is negative, the effect is reversed, and is equivalent
    # to that of <i>shiftArgument()</i>.
    #
    # === Returns
    # <i>Any</i>.  The last value in the <i>usedArgs</i> array after the
    # move.
    #
    def unshiftArgument(n=1)
      shiftArgument(-n)
    end                         # def unshiftArgument

    #
    # === Description
    # Matches the <i>sMatched</i> string from the original effector trigger
    # against the <i>reExtra</i> attribute of the <i>FormatText::Effector</i>
    # object.
    #
    # :call-seq:
    # matchExtra => <i>MatchData</i> or <tt>nil</tt>
    #
    # === Returns
    # The return value is that from the <i>String.match()</i> method,
    # which means either a <i>MatchData</i> object or else <tt>nil</tt>.
    #
    def matchExtra()
      @sMatched.match(Regexp.new(@effectorObj.reExtra))
    end                         # def matchExtra()

  end                           # class Context

  #
  # = Description
  #
  # The _FTO_ class is the user interface; all others are for
  # developers modifying or extending the +fto+ library.
  #
  # _FTO_ is a subclass of _String_, so all _String_ methods work on
  # an _FTO_ object.  _FTO_ provides the additional <i>format()</i>
  # method.
  #
  # In addition to string text, the constructor (<i>FormatText::FTO.new</i>) can
  # take more than a single argument.  Additional arguments will be
  # stored as part of the object and will be available to the
  # <i>FormatText::FTO#format()</i> method at runtime.
  #
  # An _FTO_ object can be created as just a formatting string, or the
  # constructor invocation can also include values to be applied by
  # the <i>FormatText::FTO#format()</i> method.  At runtime the
  # <i>format()</i> method can override any argument list provided
  # at instantiation, but the latter is not lost.
  #
  class FTO < String

    #
    # Class variables
    #
    #    None.
    #

    #
    # Constants
    #

    #
    # Hash of all registered effector objects, keyed by their IDs.
    #
    @@RegisteredEffectors = {} unless (defined?(@@RegisteredEffectors))

    #
    # Hash of all currently enabled effectors, keyed by their sort
    # key.
    #
    @@EnabledEffectors = {} unless (defined?(@@EnabledEffectors))

    #
    # Ordered array of effector keys (used to index
    # @@EnabledEffectors)
    #
    @@EffectorKeys = [] unless (defined?(@@EffectorKeys))

    #
    # Not yet implemented
    # Controls whether the final string is built safely and
    # conservatively, or if the output of each effector can alter the
    # input to subsequent ones.
    #
    attr_accessor :safe

    # :stopdoc:
    #
    # We do this in order to call super on String, but since our
    # argument list is different, we need to finesse it a little.
    # Nobody's business but ours.
    #
    alias_method(:String_initialize, :initialize) # :nodoc:
    # :startdoc:

    #
    # Debugging class method to access list of registered effectors
    #
    def self.effectors()        # :nodoc:
      @@RegisteredEffectors
    end                         # def self.effectors()

    #
    # Debugging class method to access list of effector keys.
    #
    def self.eKeys()            # :nodoc:
      @@EffectorKeys
    end                         # def self.eKeys()

    #
    # Debugging class method to access regular expression used to find
    # effectors.
    #
    def self.regex()            # :nodoc:
      @@regex
    end                         # def self.regex()

    #
    # === Description
    # Any argument list is supplied at object instantiation can be
    # temporarily overridden when the <i>FormatText::FTO#format()</i> method is
    # invoked.
    #
    # :call-seq:
    # new<i>()</i> => <i>FormatText::FTO</i>
    # new<i>(fmtString)</i> => <i>FormatText::FTO</i>
    # new<i>(fmtString, arg [, ...])</i> => <i>FormatText::FTO</i>
    #
    # === Arguments
    # [<i>fmtString</i>] <i>String</i>.  The actual format string containing the effectors.
    # [<i>arg</i>]    <i>Any</i>.  Optional list of one or more arguments to use when applying the effectors.
    #
    def initialize(text=nil, *args)
      String_initialize(text)
      @safe = true
      @args = args
    end                         # def initialize

    #
    # === Description
    # Remove and destroy all effectors from the list of those registered
    # (as a prelude to using a different syntax, for instance).
    # <b>THIS IS NOT REVERSIBLE!</b>
    #
    # :call-seq:
    # FTO.clearEffectorList<i>()</i> => <tt>nil</tt>
    #
    def self.clearEffectorList()
      @@RegisteredEffectors.delete_if { |id,e| true }
      self.rebuildEffectorList()
      nil
    end                         # def self.clearEffectorList()

    #
    # === Description
    # Add an effector description to the list of those which will be
    # processed by the <i>FormatText::FTO#format()</i> method.
    #
    # :call-seq:
    # FTO.registerEffector<i>(effectorObj)</i> => <tt>nil</tt>
    # FTO.registerEffector<i>(sHash)</i> => <tt>nil</tt>
    #
    # === Arguments
    # [<i>effectorObj</i>] <i>FormatText::Effector</i>.  Registers an effector tha has already been created.
    # [<i>sHash</i>] <i>Hash</i>.  A hash with symbolic keys corresponding to the attributes of the <i>FormatText::Effector</i> class.
    #
    def self.registerEffector(*args)
      if ((args.length == 1) && (args[0].class.name.match(/Effector$/)))
        newE = args[0]
      else
        newE = Effector.new('placeholder')
        if ((args.length == 1) && (args[0].class == Hash))
          args[0].each do |key,val|
            eval("newE.#{key.to_s} = val")
          end
        else
          newE = Effector.new(args)
        end
      end
      key = sprintf('%06d-%s', newE.priority, newE.name)
      newE.sortKey = key
      @@RegisteredEffectors[newE.id] = newE
      self.rebuildEffectorList()
      nil
    end                         # def self.registerEffector()

    # :stopdoc:
    #
    # This class method rebuilds the regular expression and the hash
    # of enabled effectors.  It needs to be invoked any time an
    # effector is added, destroyed, enabled, or disabled.  It's for
    # internal use only.
    #
    def self.rebuildEffectorList()
      enabled = @@RegisteredEffectors.select { |id,e| e.enabled? }
      @@EffectorKeys = []
      @@EffectorKeys = enabled.collect { |k,e| e.sortKey }.sort
      @@EffectorKeys.freeze
      @@EnabledEffectors = {}
      enabled.each { |k,e| @@EnabledEffectors[e.sortKey] = e }
      @@EnabledEffectors.freeze
      @@regex = Regexp.new("(#{@@EffectorKeys.collect {|k| @@EnabledEffectors[k].reMatch}.join(')|(')})")
      @@regex.freeze
      nil
    end                         # def self.rebuildEffectorList()
    # :startdoc:

    #
    # === Description
    # Enables the effector with the specified ID (found in the
    # effector's <i>id</i> attribute).  This is a no-op if the effector is
    # already enabled.
    #
    # :call-seq:
    # FTO.enableEffector<i>(eid)</i> => <tt>nil</tt>
    #
    # === Arguments
    # [<i>eid</i>] ID value of the effector to enable (from its <i>id</i> attribute).
    #
    # === Exceptions
    # [<tt>RuntimeError</tt>] If there is no registered effector with the specified ID.
    #
    def self.enableEffector(id)
      if ((e = @@RegisteredEffectors[id]).nil?)
        raise RuntimeError, _('No such effector ') + "ID\##{id}"
      end
      e.enabled = true
      self.rebuildEffectorList()
    end                         # def self.enableEffector()

    #
    # === Description
    # Completely removes the effector with the specified ID from the
    # FTO system.  <b>THIS IS NOT REVERSIBLE!</b>
    #
    # :call-seq:
    # FTO.destroyEffector<i>(eid)</i> => <tt>nil</tt>
    #
    # === Arguments
    # [<i>eid</i>] The value of the <i>id</i> attribute of the effector to destroy.
    #
    def self.destroyEffector(id)
      @@RegisteredEffectors.delete(id)
      self.rebuildEffectorList()
    end                         # def self.destroyEffector()

    #
    # === Description
    # Disables the effector with the specified ID (such as from
    # <i>FormatText::FTO.findEffectors()</i>).  This is a no-op
    # if the effector is already disabled.
    #
    # :call-seq:
    # FTO.disableEffector<i>(eid)</i> => <tt>nil</tt>
    #
    # === Arguments
    # [<i>eid</i>] ID value of the effector to disable (from its <i>id</i> attribute).
    #
    # === Exceptions
    # [<tt>RuntimeError</tt>] If there is no registered effector with the specified ID.
    #
    def self.disableEffector(id)
      if ((e = @@RegisteredEffectors[id]).nil?)
        raise RuntimeError, _('No such effector ') + "ID\##{id}"
      end
      e.disable
      nil
    end                         # def self.disableEffector()

    #
    # === Description
    # Returns an array of registered effectors whose names (_name_
    # attribute) match the specified pattern.
    #
    # :call-seq:
    # FTO.findEffectors<i>(sPatt)</i> => <i>Array</i>
    #
    # === Arguments
    # [<i>sPatt</i>] <i>String</i> or <i>Regexp</i>.  If called with a string as its argument, the method will create a <i>Regexp</i> object from it.  Creating the <i>Regexp</i> yourself allows you greater control, such as setting case-sensitivity for the match.
    #
    def self.findEffectors(pattern)
      pattern = Regexp.new(pattern) unless (pattern.class == Regexp)
      matches = @@RegisteredEffectors.select { |id,e| e.name.match(pattern) }
      matches.collect { |id,e| e }
    end                         # def self.findEffector()

    #
    # === Description
    # Process the formatting string, optionally with a runtime
    # argument list.  The argument list can either be a list of
    # values, an array of values, or a <i>FormatText::Context</i>
    # object.  (The latter is intended only for internal use with
    # recursion.)
    #
    # :call-seq:
    # format<i>()</i> => <i>String</i>
    # format<i>(arg [, ...])</i> => <i>String</i>
    # format<i>(Array)</i> => <i>String</i>
    # format<i>(FormatText::Context)</i> => <i>String</i> (<u>internal use only</u>)
    #
    # === Arguments
    # [none] If called with no arguments, any arglist specified at object creation (see the <i>FormatText::FTO.new()</i> method description) will be used.
    # [list of arguments] Any list of arguments will completely override any list specified at object creation time.
    # [<i>Array</i>] Rather than specifying a list of discrete arguments, you can pass a single array containing them instead.  This is useful for argument lists constructed at run-time.
    # [<i>FormatText::Context</i>] This is reserved for internal use during recursive operations.
    #
    def format(*argListp)
      argList = argListp.empty? ? @args.clone : argListp
      if ((argList.length == 1) && (argList[0].class == Array)) && 
        argList = argList[0]
      end
      #
      # It's possible we were passed a Context object so we can
      # recurse.  If so, use its values for some of these.
      #
      if ((argList.length == 1) && (argList[0].class == FormatText::Context))
        eContext = argList[0]
        usedArgs = eContext.usedArgs
        argList = eContext.argList
      else
        usedArgs = []
        eContext = Context.new({
                                 :ftoObj   => self,
                                 :usedArgs => usedArgs,
                                 :argList  => argList
                               })
      end
      input = self.to_s
      output = input.clone
      effector = sMatched = nil
      while (m = input.match(@@regex))
        #
        # Find out which effector was matched.  The index in .captures
        # will be the same as the index in @effectors.
        #
        m.captures.length.times do |i|
          next if (m.captures[i].nil?)
          eContext.effectorObj = effector = @@EnabledEffectors[@@EffectorKeys[i]]
          eContext.sMatched = sMatched = m.captures[i]
          eContext.reuseArg = false
          break
        end
        #
        # Call the workhorse for this descriptor
        #
        replacement = effector.code.call(eContext)
        output.sub!(sMatched, replacement)
        input.sub!(sMatched, '')
        #
        # Mark the item at the front of the argument list as having
        # been used, if the effector agrees.  Assume that an argument
        # was actually used if we're moving it, and that the 'last
        # argument used' hasn't changed if the effector has set
        # _reuseArg_.
        #
        unless (eContext.reuseArg)
          eContext.shiftArgument(1)
          eContext.lastArgUsed = usedArgs.last
        end
      end
      output
    end                         # def format()

  end                           # class FTO

  #
  # Class used to describe a format effector.  The
  # <i>FormatText::Effector</i> class is primarily a container rather
  # than an active class, although it does include some helper methods
  # such as <i>enable</i>, <i>enabled?</i>, <i>disable</i>, <i>disabled?</i>,
  # and <i>fillAndJustify</i>.
  #
  # Typically <i>FormatText::Effector</i> objects aren't created
  # directly, but implicitly by calling
  # <i>FormatText::FTO.registerEffector()</i>.
  #
  class Effector

    @@NEXTID = 1 unless (defined?(@@NEXTID))

    #
    # _Opaque_.  ID number assigned to the effector, unique within a
    # usage environment.  Used by <i>FormatText::FTO.enableEffector()</i>,
    # <i>FormatText::FTO.disableEffector()</i>, and
    # <i>FormatText::FTO.destroyEffector()</i>.
    #
    attr_accessor :id

    #
    # _Boolean_.  Whether this effector should be processed or
    # ignored.
    #
    attr_accessor :enabled

    #
    # _String_.  Human-readable name for what the effector does.  Used
    # for sorting.
    #
    attr_accessor :name

    #
    # _String_. Shorthand for referencing the effector; no options, field
    # widths, or the like.
    #
    attr_accessor :shortname

    #
    # _String_.  Phrase for grouping with related effectors in
    # documentation (like 'String Insertion' or 'Numeric Conversion').
    #
    attr_accessor :category

    #
    # _String_.  Human-readable syntax (HTML okey).
    #
    attr_accessor :syntax

    #
    # _String_.  Human-readable brief description.
    #
    attr_accessor :description

    #
    # _Fixnum_.  Numeric priority value for sorting purposes.
    #
    attr_accessor :priority

    #
    # _String_.  Key used to sort effectors, built from the name and
    # priority.
    #
    attr_accessor :sortKey

    #
    # _String_.  Regular expression used to recognise the effector in
    # the format string.
    #
    attr_accessor :reMatch

    #
    # _String_. Optional regex pattern used to extract additional info
    # (such as a field width).
    #
    attr_accessor :reExtra

    #
    # _Integer_.  [<i>Numeric conversion effectors only</i>] If the
    # effector is used to represent a number, this is a mask of the
    # bits to be included.  For instance, if the effector only
    # displays 8-bit values, this value would be <tt>0xFF</tt>.
    #
    attr_accessor :mask

    #
    # _Integer_.  [<i>Numeric conversion effectors only</i>] If the
    # value is to be interpreted as signed, this is a mask for the
    # sign bit.  (For a byte, <tt>:mask</tt> would be <tt>0xFF</tt>
    # and <tt>:signbit</tt> would be <tt>0x80</tt>.)
    #
    attr_accessor :signbit

    #
    # _Various_.  Default width for the effector result (used for
    # documentation and when filling).  Possible values:
    #
    # [_Integer_]           Specified number of columns.
    # [_String_]            The string is used in the documentation <i>verbatim</i>.
    # [<tt>:NA</tt>]        Default width not applicable to this effector.
    # [<tt>:asNeeded</tt>]  As many columns as are needed to represent the value.
    # [<tt>:asSpecified</tt>] As specified in the effector.
    #
    # This should be set to an integer value if needed by the effector
    # function.  All of the other possible values shown above are used
    # in generating documentation.
    #
    attr_accessor :dWidth

    #
    # _String_.  Character with which to fill the field if the actual
    # result is wider than the field width.  Default is '*'.
    #
    attr_accessor :overflowChar

    #
    # _Any_.  Default value (used if _argList_ has been exhausted).
    #
    attr_accessor :dValue

    #
    # _String_.  Character used to fill values shorter than the field
    # widths.
    #
    attr_accessor :fill

    #
    # _Symbol_.  Symbol value <tt>:left</tt> or <tt>:right</tt>,
    # indicating against which edge of a too-wide field the value
    # should abut.
    #
    attr_accessor :justify

    #
    # _Symbol_.  Symbol value <tt>:left</tt> or <tt>:right</tt>
    # indicating on which side too-wide results should be truncated to
    # fit within the field width.
    #
    attr_accessor :truncate

    #
    # _Array_.  Array of additional info for the function
    # (effector-specific).
    #
    attr_accessor :data

    #
    # _Proc_.  Code block (<i>e.g.</i>, a +lambda+ function) that
    # actually interprets the effector.  (See the
    # <i>FormatText::Context</i> class for a description, or the
    # various +Convert+ constants in the source.)
    #
    attr_accessor :code

    #
    # === Description
    # Creates a new <i>FormatText::Effector</i> object.  The argument
    # list can be either an order-dependent list of attribute values,
    # or a hash using the symbolised attribute names as the keys.
    # 
    # call-seq:
    #    new<i>(Hash)</i> => <i>FormatText::Effector</i>
    #    new<i>(name, description, enabled, priority, code, reMatch, reExtra, mask, signbit, dWidth, overflowChar, dValue, fill, justify, truncate, data, shortname)</i> => <i>FormatText::Effector</i>
    #
    # === Arguments
    # [<i>Hash</i>] <i>Hash</i>.  Hash with symbolic keys corresponding to the attributes to set.
    # [<i>name</i>, ...] <i>Various</i>.  See the documentation for the <i>FormatText::Effector</i> class' attributes for more information about each of these.
    #
    def initialize(*argsp)
      @id = @@NEXTID
      @@NEXTID += 1
      #
      # Set up defaults
      #
      (@name, @description, @code, @reMatch, @reExtra, @mask,
       @signbit, @dWidth, @dValue, @truncate) = nil
      @enabled = true
      @priority = 1000
      @data = []
      @fill = @overflowChar = @shortname = ' '
      @justify = :left
      #
      # We can either handle an order-dependent list of arguments, or
      # a hash representing keyword arguments.
      #
      args = (argsp.length == 1) ? argsp[0] : argsp
      case args.class
      when Array
        (@name, @description, @enabled, @priority, @code, @reMatch,
         @reExtra, @mask, @signbit, @dWidth, @overflowChar, @dValue,
         @fill, @justify, @truncate, @data, @shortname) = args
      when Hash
        args.each { |key,val| eval("@{key.to_s} = val") }
      end
      @data = [@data] unless (@data.nil? || (@data.class == Array))
    end                       # def initialize

    #
    # === Description
    # Disables the effector, removing it from consideration when the
    # format string is being scanned.  It can be subsequently
    # re-enabled with the <i>FormatText::Effector#enable()</i> method.
    # This is a no-op if the effector is already disabled.
    #
    # :call-seq:
    # disable<i>()</i> => <tt>nil</tt>
    #
    def disable()
      @enabled = false
      FTO.rebuildEffectorList()
    end                         # def disable()

    #
    # === Description
    # Returns <tt>true</tt> if the effector is disabled (<i>i.e.</i>,
    # inactive and not considered when scanning the format string);
    # otherwise returns <tt>false</tt>.
    #
    # :call-seq:
    # disabled? => <i>Boolean</i>
    #
    def disabled?()
      ! @enabled
    end                         # def disabled?()

    #
    # === Description
    # Enables the effector, making certain that it is considered when
    # the format string is being scanned.  This is a no-op if the
    # effector is already active.
    #
    # :call-seq:
    # enable<i>()</i> => <tt>nil</tt>
    #
    def enable()
      @enabled = true
      FTO.rebuildEffectorList()
    end                         # def enable()

    #
    # === Descriptiont
    # Returns <tt>true</tt> if the effector is enabled (<i>i.e.</i>,
    # active and considered when scanning the format string);
    # otherwise returns <tt>false</tt>.
    #
    # :call-seq:
    # enabled? => <i>Boolean</i>
    #
    def enabled?()
      @enabled
    end                         # def enabled?()

    #
    # === Description
    # Handle filling, justifying, and truncating, using the values
    # in the _Effector_ object.
    #
    # :call-seq:
    # fillAndJustify<i>(text)</i> => <i>String</i>
    # fillAndJustify<i>(text, width)</i> => <i>String</i>
    #
    # === Arguments
    # [<i>text</i>]  <i>String</i>.  Text to be formatted
    # [<i>width</i>] <i>Fixnum</i>.  Width of output field (for filling, justifying, and checking overflow)
    #
    def fillAndJustify(rText, width=nil)
      if ((! width.nil?) && (! width.to_s.empty?))
        width = width.to_i
      else
        width = (@dWidth.class.eql?(Fixnum)) ? @dWidth : nil
      end
      return rText if (width.nil?)
      width = width.to_i
      if (rText.length > width)
        case @truncate
        when :right
          rText = rText[0,width]
        when :left
          rText = rText[rText.length - width,width]
        else
          rText = @overflowChar * width
        end
      else
        #
        # The result is shorter than the width.  How do we make up the
        # difference?
        #
        fill = @fill * (width - rText.length)
        case @justify
        when :left  then rText += fill
        when :right then rText = fill + rText
        end
      end
      rText
    end                         # def fillAndJustify


  end                           # class Effector

  # :stopdoc:
  #
  # Lambda functions (for no particular reason) used by effectors.
  #

  #
  # Predefined conversion functions.  The function is passed a Context
  # object (defined above).
  #
  # The function is responsible for getting its argument from
  # argList.first.  It can modify usedArgs, argList, and reuseArg, but
  # this should be done with caution.
  #
  # The function's return value is the formatted quantity.
  #

  #
  # Placeholder effector function.
  #
  ConvertTBD = lambda {
    | eContext |
    eContext.reuseArg = true
    return 'TBD'
  }

  ConvertFixedWindow = lambda {
    | eContext |
    eObj = eContext.effectorObj
    parcels = eContext.matchExtra
    width = parcels.captures[0].sub(/</, '').to_i
    #
    # Clone the Context because we want to retain the arglist array
    # identities, but don't want to mess up any of the other aspects
    # needed by our caller.
    #
    f = FTO.new(parcels.captures[1], eContext.clone)
    sNext = f.format
    if ((diff = width - sNext.length) <= 0)
      sNext = sNext[diff.abs,width]
    else
      sNext = (' ' * diff) + sNext
    end
    eContext.reuseArg = true
    sNext
  }

  #
  # Convert a numeric argument of some sort.
  #
  ConvertNumeric = lambda {
    | eContext |
    eObj = eContext.effectorObj
    #
    # This bit of funk is so we can correctly handle a string like
    # '0xABC'.
    #
    thisArg = eval("#{eContext.getArgument()}").to_i & eObj.mask
    #
    # Sign-extend the value if appropriate.
    #
    if ((! eObj.signbit.nil?) && ((thisArg & eObj.signbit) != 0))
      thisArg |= ~ eObj.mask
    end
    #
    # See if we need to convert to a non-decimal base.
    #
    case true
    when eObj.data.include?(:octal) then replacement = thisArg.to_s(8)
    when eObj.data.include?(:hex)   then replacement = thisArg.to_s(16).upcase
    else                                 replacement = thisArg.to_s
    end
    width = eContext.matchExtra.captures[0]
    eObj.fillAndJustify(replacement, width)
  }

  #
  # Insert a string
  #
  ConvertString = lambda {
    | eContext |
    eObj = eContext.effectorObj
    if (eObj.data.include?(:lengthAsArg))
      strLen = eContext.getArgument()
      eContext.shiftArgument(1)
    end
    replacement = eContext.getArgument
    unless (strLen.nil?)
      if (strLen <= replacement.length)
        replacement = replacement[0,strLen]
      else
        replacement += "\000" * (strLen - replacement.length)
      end
    end
    replacement.gsub!(/[^[:print:]]/, '.') if (eObj.data.include?(:printable))
    eObj = eContext.effectorObj
    c = eContext.matchExtra.captures
    if (c.empty? || c[0].empty?)
      return replacement
    end
    eObj.fillAndJustify(replacement, c[0].to_i)
  }

  #
  # Insert a repeating character.
  #
  ConvertRepeatChar = lambda {
    | eContext |
    eContext.reuseArg = true
    eObj = eContext.effectorObj
    exInfo = eContext.matchExtra
    width = exInfo.captures[0].to_i
    replacement = exInfo.captures[1] * width
    return replacement
  }

  ConvertIsAre = lambda {
    | eContext |
    #
    # We don't actually use the argument list, so we need to make sure
    # the argument pointer doesn't get advanced.
    #
    eContext.reuseArg = true
    result = (eContext.usedArgs.last == 1) ? _('is') : _('are')
    result.upcase! if (eContext.sMatched == '!%IS')
    return result
  }

  ConvertPlural = lambda {
    | eContext |
    #
    # We don't actually use the argument list, so we need to make sure
    # the argument pointer doesn't get advanced.
    #
    eContext.reuseArg = true
    m2 = eContext.matchExtra
    return '' if (m2.captures[0].nil?)
    return m2.captures[0] if (eContext.usedArgs.last == 1)
    result = (m2.captures[0].upcase == 'S') ? 'es' : 's'
    result.upcase! if (m2.captures[0].match(/[A-Z]/))
    return m2.captures[0] + result
  }

  # :startdoc:

  #
  # Start registering the standard effectors.
  #
  # 1xxx String insertion
  # 2xxx Numeric insertion
  # 3xxx Special-character insertion
  # 4xxx Field-width control
  # 5xxx Argument list modification
  # 6xxx Pluralisation
  # 7xxx Miscellaneous
  #

  #
  # Strings
  # Priorities 1xxx.
  #
  FTO.registerEffector({
                         :id          => 'f0007280-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'String AS',
                         :shortname   => '!AS',
                         :category    => _('String insertion'),
                         :syntax      => '![<i>w</i>]AS',
                         :priority    => 1010,
                         :description => _('Insert a simple string.'),
                         :reMatch     => '!\d*AS',
                         :reExtra     => '!(\d*)AS',
                         :fill        => ' ',
                         :truncate    => :right,
                         :data        => [:AS],
                         :dWidth      => :asNeeded,
                         :code        => ConvertString,
                       })
  FTO.registerEffector({
                         :id          => 'f00035b0-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'String AN',
                         :shortname   => '!AN',
                         :category    => _('String insertion'),
                         :syntax      => '![<i>w</i>]AN',
                         :priority    => 1020,
                         :description => _('Insert a simple string, ' +
                                           'replacing non-printing ' +
                                           'characters with ".".'),
                         :reMatch     => '!\d*AN',
                         :reExtra     => '!(\d*)AN',
                         :fill        => ' ',
                         :truncate    => :right,
                         :data        => [:AS, :printable],
                         :dWidth      => :asSpecified,
                         :code        => ConvertString,
                       })
  FTO.registerEffector({
                         :id          => 'f0003840-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'String AD',
                         :shortname   => '!AD',
                         :category    => _('String insertion'),
                         :syntax      => '![<i>w</i>]AD',
                         :priority    => 1030,
                         :description => _('Insert the first <i>n</i> ' +
                                           'characters of a string, ' +
                                           'drawing <i>n</i> from the ' +
                                           'argument list.'),
                         :reMatch     => '!\d*AD',
                         :reExtra     => '!(\d*)AD',
                         :fill        => ' ',
                         :truncate    => :right,
                         :data        => [:lengthAsArg],
                         :dWidth      => :asSpecified,
                         :code        => ConvertString,
                       })
  FTO.registerEffector({
                         :id          => 'f00039d0-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'String AF',
                         :shortname   => '!AF',
                         :category    => _('String insertion'),
                         :syntax      => '![<i>w</i>]AF',
                         :priority    => 1040,
                         :description => _('Insert the first <i>n</i> ' +
                                           'characters of a string, ' +
                                           'drawing <i>n</i> from the ' +
                                           'argument list and replacing ' +
                                           'non-printing characters with ".".'),
                         :reMatch     => '!\d*AF',
                         :reExtra     => '!(\d*)AF',
                         :fill        => ' ',
                         :truncate    => :right,
                         :data        => [:lengthAsArg, :printable],
                         :dWidth      => :asSpecified,
                         :code        => ConvertString,
                       })

  #
  # Numeric conversions
  # Priorities 2xxx.
  #
  # === Exceptions
  # [<tt>RuntimeError</tt>] If the specified radix is outside the range of 2..36.
  #
  FTO.registerEffector({
                         :id          => 'f0003b50-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Integer arbitrary radix',
                         :shortname   => '!@R',
                         :category    => _('Numeric insertion'),
                         :syntax      => ('![<i>w</i>]@<i>radix</i>R<br/>' +
                                          '![<i>w</i>]@<i>radix</i>r<br/>' +
                                          '![<i>w</i>]@#R<br/>' +
                                          '![<i>w</i>]@#r<br/>'),
                         :priority    => 2010,
                         :description => _('Insert the value converted to ' +
                                           'the specified radix.  See the ' +
                                           'full documentation for ' +
                                           'features.'),
                         :reMatch     => '!\d*\@(?:0?#|\d{1,3})[Rr]',
                         :reExtra     => '!(\d*)\@(0?#|\d{1,3})([Rr])',
                         :dWidth      => :asNeeded,
                         :code        => lambda {
                           | eContext |
                           arg = eContext.getArgument
                           m = eContext.matchExtra
                           radix = m.captures[1]
                           if (radix.match(Regexp.new('^0?\#$')))
                             eContext.shiftArgument
                             radix = arg
                             arg = eContext.getArgument
                           end
                           radix = radix.to_i
                           unless (radix.between?(2, 36))
                             raise RuntimeError,
                               _("Illegal radix '#{radix}'; only 2..36 allowed")
                           end
                           result = arg.to_s(radix)
                           unless ((width = m.captures[0]).empty?)
                             width = width.to_i
                             if (result.length > width)
                               result = '*' * width
                             else
                               nFill = width - result.length
                               if (m.captures[1][0,1].eql?('0'))
                                 result = ('0' * nFill) + result
                               else
                                 result += ' ' * nFill
                               end
                             end
                           end
                           result.upcase! if (m.captures[2].eql?('R'))
                           result
                         },
                       })
  FTO.registerEffector({
                         :id          => 'f0003cc0-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Floating-point',
                         :shortname   => '!F',
                         :category    => _('Numeric insertion'),
                         :syntax      => '![<i>w</i>]F',
                         :priority    => 2020,
                         :description => _('Insert the decimal ' +
                                           'representation of an unsigned ' +
                                           '8-bit value, left space-filled ' +
                                           'to the field width.'),
                         :reMatch     => '!\d*UB',
                         :reExtra     => '!(\d*)UB',
                         :mask        => 0xFF,
                         :dWidth      => :asNeeded,
                         :code        => ConvertNumeric,
                       })
  FTO.registerEffector({
                         :id          => 'f0003e30-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Byte: unsigned',
                         :shortname   => '!UB',
                         :category    => _('Numeric insertion'),
                         :syntax      => '![<i>w</i>]UB',
                         :priority    => 2030,
                         :description => _('Insert the decimal ' +
                                           'representation of an unsigned ' +
                                           '8-bit value, left space-filled ' +
                                           'to the field width.'),
                         :reMatch     => '!\d*UB',
                         :reExtra     => '!(\d*)UB',
                         :mask        => 0xFF,
                         :dWidth      => :asNeeded,
                         :code        => ConvertNumeric,
                       })
  FTO.registerEffector({
                         :id          => 'f0004040-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Byte: signed',
                         :shortname   => '!SB',
                         :category    => _('Numeric insertion'),
                         :syntax      => '![<i>w</i>]SB',
                         :priority    => 2040,
                         :description => _('Insert the decimal ' +
                                           'representation of a signed ' +
                                           '8-bit value, left space-filled ' +
                                           'to the field width.'),
                         :reMatch     => '!\d*SB',
                         :reExtra     => '!(\d*)SB',
                         :mask        => 0xFF,
                         :signbit     => 0x80,
                         :dWidth      => :asNeeded,
                         :code        => ConvertNumeric,
                       })
  FTO.registerEffector({
                         :id          => 'f00041b0-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Byte: unsigned, zero-filled',
                         :shortname   => '!ZB',
                         :category    => _('Numeric insertion'),
                         :syntax      => '![<i>w</i>]ZB',
                         :priority    => 2050,
                         :description => _('Insert the decimal ' +
                                           'representation of an unsigned ' +
                                           '8-bit value, left zero-filled ' +
                                           'to the field width.'),
                         :reMatch     => '!\d*ZB',
                         :reExtra     => '!(\d*)ZB',
                         :mask        => 0xFF,
                         :fill        => '0',
                         :justify     => :right,
                         :dWidth      => :asNeeded,
                         :code        => ConvertNumeric,
                       })
  FTO.registerEffector({
                         :id          => 'f0004330-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Byte: octal',
                         :shortname   => '!OB',
                         :category    => _('Numeric insertion'),
                         :syntax      => '![<i>w</i>]OB',
                         :priority    => 2060,
                         :description => _('Insert the octal ' +
                                           'representation of an unsigned ' +
                                           '8-bit value, left zero-filled ' +
                                           'to the field width (default ' +
                                           '3).'),
                         :reMatch     => '!\d*OB',
                         :reExtra     => '!(\d*)OB',
                         :mask        => 0xFF,
                         :dWidth      => 3,
                         :fill        => '0',
                         :justify     => :right,
                         :truncate    => :left,
                         :data        => [:octal],
                         :code        => ConvertNumeric,
                       })
  FTO.registerEffector({
                         :id          => 'f00044a0-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Byte: hex',
                         :shortname   => '!XB',
                         :category    => _('Numeric insertion'),
                         :syntax      => '![<i>w</i>]XB',
                         :priority    => 2070,
                         :description => _('Insert the hexadecimal ' +
                                           'representation of an unsigned ' +
                                           '8-bit value, left zero-filled ' +
                                           'to the field width (default ' +
                                           '2).'),
                         :reMatch     => '!\d*XB',
                         :reExtra     => '!(\d*)XB',
                         :mask        => 0xFF,
                         :dWidth      => 2,
                         :fill        => '0',
                         :justify     => :right,
                         :truncate    => :left,
                         :data        => [:hex],
                         :code        => ConvertNumeric,
                       })
  FTO.registerEffector({
                         :id          => 'f0004620-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Word: unsigned',
                         :shortname   => '!UW',
                         :category    => _('Numeric insertion'),
                         :syntax      => '![<i>w</i>]UW',
                         :priority    => 2110,
                         :description => _('Insert the decimal ' +
                                           'representation of an unsigned ' +
                                           '16-bit value, left space-filled ' +
                                           'to the field width.'),
                         :reMatch     => '!\d*UW',
                         :reExtra     => '!(\d*)UW',
                         :mask        => 0xFFFF,
                         :dWidth      => :asNeeded,
                         :code        => ConvertNumeric,
                       })
  FTO.registerEffector({
                         :id          => 'f0004790-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Word: signed',
                         :shortname   => '!SW',
                         :category    => _('Numeric insertion'),
                         :syntax      => '![<i>w</i>]SW',
                         :priority    => 2120,
                         :description => _('Insert the decimal ' +
                                           'representation of a signed ' +
                                           '16-bit value, left space-filled ' +
                                           'to the field width.'),
                         :reMatch     => '!\d*SW',
                         :reExtra     => '!(\d*)SW',
                         :mask        => 0xFFFF,
                         :signbit     => 0x8000,
                         :dWidth      => :asNeeded,
                         :code        => ConvertNumeric,
                       })
  FTO.registerEffector({
                         :id          => 'f0004910-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Word: unsigned, zero-filled',
                         :shortname   => '!ZW',
                         :category    => _('Numeric insertion'),
                         :syntax      => '![<i>w</i>]ZW',
                         :priority    => 2130,
                         :description => _('Insert the decimal ' +
                                           'representation of an unsigned ' +
                                           '16-bit value, left zero-filled ' +
                                           'to the field width.'),
                         :reMatch     => '!\d*ZW',
                         :reExtra     => '!(\d*)ZW',
                         :mask        => 0xFFFF,
                         :fill        => '0',
                         :justify     => :right,
                         :dWidth      => :asNeeded,
                         :code        => ConvertNumeric,
                       })
  FTO.registerEffector({
                         :id          => 'f0004ac0-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Word: octal',
                         :shortname   => '!OW',
                         :category    => _('Numeric insertion'),
                         :syntax      => '![<i>w</i>]OW',
                         :priority    => 2140,
                         :description => _('Insert the octal ' +
                                           'representation of an unsigned ' +
                                           '16-bit value, left zero-filled ' +
                                           'to the field width (default ' +
                                           '6).'),
                         :reMatch     => '!\d*OW',
                         :reExtra     => '!(\d*)OW',
                         :mask        => 0xFFFF,
                         :dWidth      => 6,
                         :fill        => '0',
                         :justify     => :right,
                         :truncate    => :left,
                         :data        => [:octal],
                         :code        => ConvertNumeric,
                       })
  FTO.registerEffector({
                         :id          => 'f0004c40-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Word: hex',
                         :shortname   => '!XW',
                         :category    => _('Numeric insertion'),
                         :syntax      => '![<i>w</i>]XW',
                         :priority    => 2150,
                         :description => _('Insert the hexadecimal ' +
                                           'representation of an unsigned ' +
                                           '16-bit value, left zero-filled ' +
                                           'to the field width (default ' +
                                           '4).'),
                         :reMatch     => '!\d*XW',
                         :reExtra     => '!(\d*)XW',
                         :mask        => 0xFFFF,
                         :dWidth      => 4,
                         :fill        => '0',
                         :justify     => :right,
                         :truncate    => :left,
                         :data        => [:hex],
                         :code        => ConvertNumeric,
                       })
  FTO.registerEffector({
                         :id          => 'f0004db0-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Long: unsigned',
                         :shortname   => '!UL',
                         :category    => _('Numeric insertion'),
                         :syntax      => '![<i>w</i>]UL',
                         :priority    => 2210,
                         :description => _('Insert the decimal ' +
                                           'representation of an unsigned ' +
                                           '32-bit value, left space-filled ' +
                                           'to the field width.'),
                         :reMatch     => '!\d*UL',
                         :reExtra     => '!(\d*)UL',
                         :mask        => 0xFFFFFFFF,
                         :dWidth      => :asNeeded,
                         :code        => ConvertNumeric,
                       })
  FTO.registerEffector({
                         :id          => 'f0004f20-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Long: signed',
                         :shortname   => '!SL',
                         :category    => _('Numeric insertion'),
                         :syntax      => '![<i>w</i>]SL',
                         :priority    => 2220,
                         :description => _('Insert the decimal ' +
                                           'representation of a signed ' +
                                           '32-bit value, left space-filled ' +
                                           'to the field width.'),
                         :reMatch     => '!\d*SL',
                         :reExtra     => '!(\d*)SL',
                         :mask        => 0xFFFFFFFF,
                         :signbit     => 0x80000000,
                         :dWidth      => :asNeeded,
                         :code        => ConvertNumeric,
                       })
  FTO.registerEffector({
                         :id          => 'f00050a0-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Long: unsigned, zero-filled',
                         :shortname   => '!ZL',
                         :category    => _('Numeric insertion'),
                         :syntax      => '![<i>w</i>]ZL',
                         :priority    => 2230,
                         :description => _('Insert the decimal ' +
                                           'representation of an unsigned ' +
                                           '32-bit value, left zero-filled ' +
                                           'to the field width.'),
                         :reMatch     => '!\d*ZL',
                         :reExtra     => '!(\d*)ZL',
                         :mask        => 0xFFFFFFFF,
                         :fill        => '0',
                         :justify     => :right,
                         :dWidth      => :asNeeded,
                         :code        => ConvertNumeric,
                       })
  FTO.registerEffector({
                         :id          => 'f0005210-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Long: octal',
                         :shortname   => '!OL',
                         :category    => _('Numeric insertion'),
                         :syntax      => '![<i>w</i>]OL',
                         :priority    => 2240,
                         :description => _('Insert the octal ' +
                                           'representation of an unsigned ' +
                                           '32-bit value, left zero-filled ' +
                                           'to the field width (default ' +
                                           '11).'),
                         :reMatch     => '!\d*OL',
                         :reExtra     => '!(\d*)OL',
                         :mask        => 0xFFFFFFFF,
                         :dWidth      => 11,
                         :fill        => '0',
                         :justify     => :right,
                         :truncate    => :left,
                         :data        => [:octal],
                         :code        => ConvertNumeric,
                       })
  FTO.registerEffector({
                         :id          => 'f0005380-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Long: hex',
                         :shortname   => '!XL',
                         :category    => _('Numeric insertion'),
                         :syntax      => '![<i>w</i>]XL',
                         :priority    => 2250,
                         :description => _('Insert the hexadecimal ' +
                                           'representation of an unsigned ' +
                                           '32-bit value, left zero-filled ' +
                                           'to the field width (default ' +
                                           '8).'),
                         :reMatch     => '!\d*XL',
                         :reExtra     => '!(\d*)XL',
                         :mask        => 0xFFFFFFFF,
                         :dWidth      => 8,
                         :fill        => '0',
                         :justify     => :right,
                         :truncate    => :left,
                         :data        => [:hex],
                         :code        => ConvertNumeric,
                       })
  FTO.registerEffector({
                         :id          => 'f00054f0-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Quadword: unsigned',
                         :shortname   => '!UQ',
                         :category    => _('Numeric insertion'),
                         :syntax      => '![<i>w</i>]UQ',
                         :priority    => 2310,
                         :description => _('Insert the decimal ' +
                                           'representation of an unsigned ' +
                                           '64-bit value, left space-filled ' +
                                           'to the field width.'),
                         :reMatch     => '!\d*UQ',
                         :reExtra     => '!(\d*)UQ',
                         :mask        => 0xFFFFFFFFFFFFFFFF,
                         :dWidth      => :asNeeded,
                         :code        => ConvertNumeric,
                       })
  FTO.registerEffector({
                         :id          => 'f0005670-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Quadword: signed',
                         :shortname   => '!SQ',
                         :category    => _('Numeric insertion'),
                         :syntax      => '![<i>w</i>]SQ',
                         :priority    => 2320,
                         :description => _('Insert the decimal ' +
                                           'representation of a signed ' +
                                           '64-bit value, left space-filled ' +
                                           'to the field width.'),
                         :reMatch     => '!\d*SQ',
                         :reExtra     => '!(\d*)SQ',
                         :mask        => 0xFFFFFFFFFFFFFFFF,
                         :signbit     => 0x8000000000000000,
                         :dWidth      => :asNeeded,
                         :code        => ConvertNumeric,
                       })
  FTO.registerEffector({
                         :id          => 'f00057e0-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Quadword: unsigned, zero-filled',
                         :shortname   => '!ZQ',
                         :category    => _('Numeric insertion'),
                         :syntax      => '![<i>w</i>]ZQ',
                         :priority    => 2330,
                         :description => _('Insert the decimal ' +
                                           'representation of an unsigned ' +
                                           '64-bit value, left zero-filled ' +
                                           'to the field width.'),
                         :reMatch     => '!\d*ZQ',
                         :reExtra     => '!(\d*)ZQ',
                         :mask        => 0xFFFFFFFFFFFFFFFF,
                         :fill        => '0',
                         :justify     => :right,
                         :dWidth      => :asNeeded,
                         :code        => ConvertNumeric,
                       })
  FTO.registerEffector({
                         :id          => 'f0005960-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Quadword: octal',
                         :shortname   => '!OQ',
                         :category    => _('Numeric insertion'),
                         :syntax      => '![<i>w</i>]OQ',
                         :priority    => 2340,
                         :description => _('Insert the octal ' +
                                           'representation of an unsigned ' +
                                           '64-bit value, left zero-filled ' +
                                           'to the field width (default ' +
                                           '22).'),
                         :reMatch     => '!\d*OQ',
                         :reExtra     => '!(\d*)OQ',
                         :mask        => 0xFFFFFFFFFFFFFFFF,
                         :dWidth      => 22,
                         :fill        => '0',
                         :justify     => :right,
                         :truncate    => :left,
                         :data        => [:octal],
                         :code        => ConvertNumeric,
                       })
  FTO.registerEffector({
                         :id          => 'f0005ac0-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Quadword: hex',
                         :shortname   => '!XQ',
                         :category    => _('Numeric insertion'),
                         :syntax      => '![<i>w</i>]XQ',
                         :priority    => 2350,
                         :description => _('Insert the hexadecimal ' +
                                           'representation of an unsigned ' +
                                           '64-bit value, left zero-filled ' +
                                           'to the field width (default ' +
                                           '16).'),
                         :reMatch     => '!\d*XQ',
                         :reExtra     => '!(\d*)XQ',
                         :mask        => 0xFFFFFFFFFFFFFFFF,
                         :dWidth      => 16,
                         :fill        => '0',
                         :justify     => :right,
                         :truncate    => :left,
                         :data        => [:hex],
                         :code        => ConvertNumeric,
                       })

  #
  # The simple replacements ('insert a TAB', etc.).
  # Priorities 3xxx.
  #
  FTO.registerEffector({
                         :id          => 'f0005c40-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'TAB',
                         :shortname   => '!_',
                         :category    => _('Special-character insertion'),
                         :syntax      => '!_',
                         :priority    => 3010,
                         :description => _('Insert a TAB character.'),
                         :reMatch     => '!_',
                         :dWidth      => :NA,
                         :code        => lambda {
                           | eContext |
                           eContext.reuseArg = true
                           return "\011"
                         }
                       })
  FTO.registerEffector({
                         :id          => 'f0005db0-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Formfeed',
                         :shortname   => '!^',
                         :category    => _('Special-character insertion'),
                         :syntax      => '!^',
                         :priority    => 3020,
                         :description => _('Insert a form-feed control ' +
                                           'character.'),
                         :reMatch     => '!\^',
                         :dWidth      => :NA,
                         :code        => lambda {
                           | eContext |
                           eContext.reuseArg = true
                           return "\014"
                         }
                       })
  FTO.registerEffector({
                         :id          => 'f0005f20-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Bang',
                         :shortname   => '!!',
                         :category    => _('Special-character insertion'),
                         :syntax      => '!!',
                         :priority    => 3030,
                         :description => _('Insert an exclamation mark ' +
                                           '(!) character.'),
                         :reMatch     => '!!',
                         :dWidth      => :NA,
                         :code        => lambda {
                           | eContext |
                           eContext.reuseArg = true
                           return '!'
                         }
                       })
  FTO.registerEffector({
                         :id          => 'f0006090-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'CR',
                         :shortname   => '!=',
                         :category    => _('Special-character insertion'),
                         :syntax      => '!=',
                         :priority    => 3040,
                         :description => _('Insert a carriage-return ' +
                                           'character.'),
                         :reMatch     => '!=',
                         :dWidth      => :NA,
                         :code        => lambda {
                           | eContext |
                           eContext.reuseArg = true
                           return "\015"
                         }
                       })
  FTO.registerEffector({
                         :id          => 'f0006200-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'LF',
                         :shortname   => '!,',
                         :category    => _('Special-character insertion'),
                         :syntax      => '!,',
                         :priority    => 3050,
                         :description => _('Insert a line-feed control ' +
                                           'character.'),
                         :reMatch     => '!,',
                         :dWidth      => :NA,
                         :code        => lambda {
                           | eContext |
                           eContext.reuseArg = true
                           return "\012"
                         }
                       })
  FTO.registerEffector({
                         :id          => 'f0006380-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'CRLF',
                         :shortname   => '!/',
                         :category    => _('Special-character insertion'),
                         :syntax      => '!/',
                         :priority    => 3060,
                         :description => _('Insert a carriage-return and ' +
                                           'a line-feed.'),
                         :reMatch     => '!/',
                         :dWidth      => :NA,
                         :code        => lambda {
                           | eContext |
                           eContext.reuseArg = true
                           return "\015\012"
                         }
                       })

  #
  # Field-width control.
  # Priorities 4xxx.
  #
  FTO.registerEffector({
                         :id          => 'f00064f0-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'ArgWidth',
                         :shortname   => '!#',
                         :category    => _('Field-width control'),
                         :syntax      => '!#<i>effector</i>',
                         :priority    => 4010,
                         :description => _('Specify a field width using ' +
                                           'an argument rather than a ' +
                                           'hard-coded value.'),
                         :reMatch     => '!#',
                         :dWidth      => :NA,
                         :code        => lambda {
                           | eContext |
                           n = eContext.getArgument
                           return "!#{n.to_i.to_s}"
                         }
                       })
  FTO.registerEffector({
                         :id          => 'f00066f0-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Fixed Window',
                         :shortname   => '!n<>',
                         :category    => _('Field-width control'),
                         :syntax      => '!<i>w</i>&lt; ... !&gt;',
                         :priority    => 4020,
                         :description => _('Force a right-justified field ' +
                                           'width on the contents between ' +
                                           'the effector delimiters.'),
                         :reMatch     => '!\d+<.*!>',
                         :reExtra     => '!(\d+<)(.*)(!>)',
                         :fill        => ' ',
                         :truncate    => :right,
                         :justify     => :right,
                         :dWidth      => :NA,
                         :code        => ConvertFixedWindow,
                       })

  #
  # Effectors that frob the argument list.
  # Priorities 5xxx.
  #
  FTO.registerEffector({
                         :id          => 'f0006870-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Reuse',
                         :shortname   => '!-',
                         :category    => _('Argument list modification'),
                         :syntax      => '!-',
                         :priority    => 5010,
                         :description => _('Back the argument list up ' +
                                           'so the most recently used ' +
                                           ' argument gets re-used.'),
                         :reMatch     => '!-',
                         :dWidth      => :NA,
                         :code        => lambda {
                           | eContext |
                           eContext.reuseArg = true
                           eContext.unshiftArgument
                           return ''
                         }
                       })
  FTO.registerEffector({
                         :id          => 'f00069e0-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Skip',
                         :shortname   => '!+',
                         :category    => _('Argument list modification'),
                         :syntax      => '!+',
                         :priority    => 5020,
                         :description => _('Skip over the next item in ' +
                                           'the argument list.'),
                         :reMatch     => '!\+',
                         :dWidth      => :NA,
                         :code        => lambda {
                           | eContext |
                           eContext.shiftArgument(1)
                           return ''
                         }
                       })

  #
  # Pluralisation.
  # Priorities 6xxx.
  #
  FTO.registerEffector({
                         :id          => 'f0006b50-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Pluralise-English',
                         :shortname   => '!%S',
                         :category    => _('Pluralisation'),
                         :syntax      => '!%S',
                         :priority    => 6010,
                         :description => _('Add an "s" or "es" suffix if ' +
                                           'the last argument used was not 1.'),
                         :reMatch     => '.?!%S',
                         :reExtra     => '(.)?!%S',
                         :dWidth      => _('1 or 2 columns'),
                         :code        => ConvertPlural,
                       })
  FTO.registerEffector({
                         :id          => 'f0006cb0-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'is/are-English',
                         :shortname   => '!%is',
                         :category    => _('Pluralisation'),
                         :syntax      => '!%is',
                         :priority    => 6020,
                         :description => _('Insert "is" or "are" depending ' +
                                           'on whether the last argument ' +
                                           'used was 1.'),
                         :reMatch     => '!%is',
                         :dWidth      => _('2 or 3 columns'),
                         :code        => ConvertIsAre,
                       })
  FTO.registerEffector({
                         :id          => 'f0006e20-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'IS/ARE-English',
                         :shortname   => '!%IS',
                         :category    => _('Pluralisation'),
                         :syntax      => '!%IS',
                         :priority    => 6030,
                         :description => _('Insert "IS" or "ARE" depending ' +
                                           'on whether the last argument ' +
                                           'used was 1.'),
                         :reMatch     => '!%IS',
                         :dWidth      => _('2 or 3 columns'),
                         :code        => ConvertIsAre,
                       })

  #
  # Miscellaneous.
  # Priorities 7xxx.
  #
  FTO.registerEffector({
                         :id          => 'f0006fa0-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'Date/Time',
                         :shortname   => '!%T',
                         :category    => _('Date/time insertion'),
                         :syntax      => '![<i>w</i>]%T( ... !)',
                         :priority    => 7010,
                         :description => _('Format a date/time value ' +
                                           'using <tt>strftime(3)</tt> rules ' +
                                           'and insert the result.'),
                         :reMatch     => '!\d*%T\([^)]*!\)',
                         :reExtra     => '!(\d*)%T\(([^)]*)!\)',
                         :fill        => ' ',
                         :dWidth      => _('Depends on the time formatting ' +
                                           'string.'),
                         :code        => lambda {
                           | eContext |
                           t = eContext.getArgument
                           t = Time.now if (t.eql?(0))
                           eObj = eContext.effectorObj
                           sMatched = eContext.sMatched
                           parcels = eContext.matchExtra
                           result = t.strftime(parcels.captures[1])
                           unless (parcels.captures[0].eql?(''))
                             rWidth = parcels.captures[0].to_i
                             if ((diff = rWidth - result.length) < 0)
                               result = result[0,rWidth]
                             else
                               result += eObj.fill * diff
                             end
                           end
                           return result
                         }
                       })
  FTO.registerEffector({
                         :id          => 'f0007110-c841-012c-34b5-0022fa8d53c2',
                         :name        => 'RepeatingChar',
                         :shortname   => '!n*c',
                         :category    => _('Miscellaneous'),
                         :syntax      => '!<i>n</i>*<i>c</i>',
                         :priority    => 7020,
                         :description => _('Insert <i>n</i> occurrences of ' +
                                           'a character.'),
                         :reMatch     => '!\d+\*.',
                         :reExtra     => '!(\d+)\*(.)',
                         :dWidth      => :NA,
                         :code        => ConvertRepeatChar,
                       })

  true
end                             # module FTO

# Local Variables:
# mode: ruby
# indent-tabs-mode: nil
# eval: (if (intern-soft "fci-mode") (fci-mode 1))
# End:
