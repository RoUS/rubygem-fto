require 'rubygems'
require File.dirname(__FILE__) + '/test_helper.rb'

module FormatText

  module Tests

    class Test_API < Test::Unit::TestCase

      private

      def setup
      end

      def test_truth
        assert true
      end

      public

      def test_001_arglistOverride()
        cValue = 'construction value'
        oValue = 'override value'
        f = FTO.new('!AS', cValue)
        assert_equal(cValue, f.format)
        assert_equal(oValue, f.format(oValue))
        assert_equal(cValue, f.format)
      end                       # def test_arglistOverride()

      def test_002_findEffectors()
        #
        # Check for not finding anything
        #
        pattern = 'No such string'
        assert(FTO::findEffectors(pattern).empty?)
        assert(FTO::findEffectors(Regexp.new(pattern)).empty?)

        #
        # Check for finding exactly one match
        #
        pattern = '^TAB$'
        assert(FTO::findEffectors(pattern).length == 1)
        assert(FTO::findEffectors(Regexp.new(pattern)).length == 1)

        #
        # Make sure we're getting the right thing.
        #
        assert(FTO::findEffectors(pattern).first.class.name.match(/Effector/))

        #
        # Check for fiddling with case
        #
        pattern = '^tab$'
        assert(FTO::findEffectors(pattern).empty?)
        assert(FTO::findEffectors(Regexp.new(pattern, Regexp::IGNORECASE)).length == 1)

        #
        # Check for finding a few ('String AS', 'String AN', 'String AD',
        # and 'String AF').
        # Anchored pattern.
        #
        pattern = '^String'
        assert(FTO::findEffectors(pattern).length == 4)
        assert(FTO::findEffectors(Regexp.new(pattern)).length == 4)

        #
        # Check for finding a few ('Word: hex' and 'Quadword: hex').
        # Unanchored pattern.
        #
        pattern = 'rd: he'
        assert(FTO::findEffectors(pattern).length == 2)
        assert(FTO::findEffectors(Regexp.new(pattern)).length == 2)
      end                       # def test_findEffectors()

      def test_003_EnableDisableEffector()
        e = FTO.findEffectors('^String AS$').first
        #
        # Check the switches and sensors around enablement.  (Whether they
        # actually do their jobs is next.)
        #

        #
        # Instance methods checking an effector enabled by instance method.
        # (Actually, by assumed default.)
        #
        assert(e.enabled?,
               'Instance check that !AS is enabled by default')
        assert(! e.disabled?,
               'Instance check that !AS is not disabled by default')

        #
        # Instance methods checking state altered by class method.
        #
        FTO.disableEffector(e.id)
        assert(! e.enabled?,
               'Instance check that class method disable works (! enabled?)')
        assert(e.disabled?,
               'Instance check that class method disable works (disabled?')

        FTO.enableEffector(e.id)
        assert(e.enabled?,
               'Instance check that class method enable works (enabled?)')
        assert(! e.disabled?,
               'Instance check that class method enable works (! disabled?)')

        #
        # *Now* instance methods checking on effect of other instance methods.
        #
        e.disable
        assert(! e.enabled?,
               'Instance check that instance method disable works (! enabled?)')
        assert(e.disabled?,
               'Instance check that instance method disable works (disabled?)')

        e.enable
        assert(e.enabled?,
               'Instance check that instance method enable works (enabled?)')
        assert(! e.disabled?,
               'Instance check that instance method enable works (! disabled?)')

        #
        # Now time to see if this enable/disable stuff is really doing what it
        # ought.
        #
        pattern = '!AS'
        f = FTO.new(pattern, 'succeeded')
        #
        # Test reality of disablement using the Effector.disable method.
        #
        e.disable
        assert_equal(pattern,
                     f.format('succeeded'),
                     'Checking that instance-disabled !AS("succeeded") == "!AS"')
        #
        # Test reality of enablement using the FTO class method.
        #
        FTO.enableEffector(e.id)
        assert_equal('succeeded',
                     f.format('succeeded'),
                     'Checking that class-enabled !AS("succeeded") == "succeeded"')

        #
        # And contrariwise.  Class method first.
        #
        FTO.disableEffector(e.id)
        assert_equal(pattern,
                     f.format('succeeded'),
                     'Checking that class-disabled !AS("succeeded") == "!AS"')
        #
        # Then instance method.
        #
        e.enable
        assert_equal('succeeded',
                     f.format('succeeded'),
                     'Checking that instance-enabled !AS("succeeded") == "succeeded"')
        #
        # Make sure we leave it on!
        #
        FTO.enableEffector(e.id)
      end                       # def test_EnableDisableEffector()

      def test_004_clearEffectorList()
        assert(! FTO.findEffectors('^').empty?)
        FTO.clearEffectorList()
        assert(FTO.findEffectors('^').empty?)
      end                       # def test_clearEffectorList()

    end                         # class Test_API

  end                           # module Tests

end                             # module FormatText
