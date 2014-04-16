require File.dirname(__FILE__) + '/test_helper.rb'

#
# @TODO:
#  Oops, I think 'safe mode' makes !# no workee..
#

module FormatText

  module Tests

    class Test_Effectors < Test::Unit::TestCase

#  include FormatText

      private

      def setup
      end

      def test_truth
        assert true
      end

      def test_numeric_singleton(eff, val, expected)
        assert_equal(expected, FTO.new(eff, val).format,
                     'Testing ' + eff + '/' + val)
      end

      public

      def test_001_insertions()
        assert_equal(FTO.new('!_').format, "\011", 'Testing !_')
        assert_equal(FTO.new('!,').format, "\012", 'Testing !,')
        assert_equal(FTO.new('!^').format, "\014", 'Testing !^')
        assert_equal(FTO.new('!=').format, "\015", 'Testing !=')
        assert_equal(FTO.new('!/').format, "\015\012", 'Testing !/')
        assert_equal(FTO.new('!!').format, '!', 'Testing !!')
        assert_equal(FTO.new('!5**').format, '*****', 'Testing !n*c')
      end                       # def test_001_insertions()

      def test_002_unsized()
        expectations = {
          '-1'                 => '255',
          '0'                  => '0',
          '1'                  => '1',
          '0x100'              => '0',
          '0xFFF'              => '255',
          '0xFFFF'             => '255',
          '0xFFFFF'            => '255',
          '0xFFFFFF'           => '255',
          '0xFFFFFFF'          => '255',
          '0xFFFFFFFF'         => '255',
          '0xFFFFFFFFF'        => '255',
          '0xFFFFFFFFFF'       => '255',
          '0xFFFFFFFFFFF'      => '255',
          '0xFFFFFFFFFFFF'     => '255',
          '0xFFFFFFFFFFFFF'    => '255',
          '0xFFFFFFFFFFFFFF'   => '255',
          '0xFFFFFFFFFFFFFFF'  => '255',
          '0xFFFFFFFFFFFFFFFF' => '255',
        }
        expectations.each { |val, exp| test_numeric_singleton('!UB', val, exp) }

        expectations = {
          '-1'                 => '-1',
          '0'                  => '0',
          '1'                  => '1',
          '0x100'              => '0',
          '0xFFF'              => '-1',
          '0xFFFF'             => '-1',
          '0xFFFFF'            => '-1',
          '0xFFFFFF'           => '-1',
          '0xFFFFFFF'          => '-1',
          '0xFFFFFFFF'         => '-1',
          '0xFFFFFFFFF'        => '-1',
          '0xFFFFFFFFFF'       => '-1',
          '0xFFFFFFFFFFF'      => '-1',
          '0xFFFFFFFFFFFF'     => '-1',
          '0xFFFFFFFFFFFFF'    => '-1',
          '0xFFFFFFFFFFFFFF'   => '-1',
          '0xFFFFFFFFFFFFFFF'  => '-1',
          '0xFFFFFFFFFFFFFFFF' => '-1',
        }
        expectations.each { |val, exp| test_numeric_singleton('!SB', val, exp) }

        expectations = {
          '-1'                 => '255',
          '0'                  => '0',
          '1'                  => '1',
          '0x100'              => '0',
          '0xFFF'              => '255',
          '0xFFFF'             => '255',
          '0xFFFFF'            => '255',
          '0xFFFFFF'           => '255',
          '0xFFFFFFF'          => '255',
          '0xFFFFFFFF'         => '255',
          '0xFFFFFFFFF'        => '255',
          '0xFFFFFFFFFF'       => '255',
          '0xFFFFFFFFFFF'      => '255',
          '0xFFFFFFFFFFFF'     => '255',
          '0xFFFFFFFFFFFFF'    => '255',
          '0xFFFFFFFFFFFFFF'   => '255',
          '0xFFFFFFFFFFFFFFF'  => '255',
          '0xFFFFFFFFFFFFFFFF' => '255',
        }
        expectations.each { |val, exp| test_numeric_singleton('!ZB', val, exp) }

        expectations = {
          '-1'                 => '377',
          '0'                  => '000',
          '1'                  => '001',
          '0x100'              => '000',
          '0xFFF'              => '377',
          '0xFFFF'             => '377',
          '0xFFFFF'            => '377',
          '0xFFFFFF'           => '377',
          '0xFFFFFFF'          => '377',
          '0xFFFFFFFF'         => '377',
          '0xFFFFFFFFF'        => '377',
          '0xFFFFFFFFFF'       => '377',
          '0xFFFFFFFFFFF'      => '377',
          '0xFFFFFFFFFFFF'     => '377',
          '0xFFFFFFFFFFFFF'    => '377',
          '0xFFFFFFFFFFFFFF'   => '377',
          '0xFFFFFFFFFFFFFFF'  => '377',
          '0xFFFFFFFFFFFFFFFF' => '377',
        }
        expectations.each { |val, exp| test_numeric_singleton('!OB', val, exp) }

        expectations = {
          '-1'                 => 'FF',
          '0'                  => '00',
          '1'                  => '01',
          '0x100'              => '00',
          '0xFFF'              => 'FF',
          '0xFFFF'             => 'FF',
          '0xFFFFF'            => 'FF',
          '0xFFFFFF'           => 'FF',
          '0xFFFFFFF'          => 'FF',
          '0xFFFFFFFF'         => 'FF',
          '0xFFFFFFFFF'        => 'FF',
          '0xFFFFFFFFFF'       => 'FF',
          '0xFFFFFFFFFFF'      => 'FF',
          '0xFFFFFFFFFFFF'     => 'FF',
          '0xFFFFFFFFFFFFF'    => 'FF',
          '0xFFFFFFFFFFFFFF'   => 'FF',
          '0xFFFFFFFFFFFFFFF'  => 'FF',
          '0xFFFFFFFFFFFFFFFF' => 'FF',
        }
        expectations.each { |val, exp| test_numeric_singleton('!XB', val, exp) }

        #
        # Now the 16-bit word effectors
        #
        expectations = {
          '-1'                 => '65535',
          '0'                  => '0',
          '1'                  => '1',
          '0x100'              => '256',
          '0xFFF'              => '4095',
          '0xFFFF'             => '65535',
          '0xFFFFF'            => '65535',
          '0xFFFFFF'           => '65535',
          '0xFFFFFFF'          => '65535',
          '0xFFFFFFFF'         => '65535',
          '0xFFFFFFFFF'        => '65535',
          '0xFFFFFFFFFF'       => '65535',
          '0xFFFFFFFFFFF'      => '65535',
          '0xFFFFFFFFFFFF'     => '65535',
          '0xFFFFFFFFFFFFF'    => '65535',
          '0xFFFFFFFFFFFFFF'   => '65535',
          '0xFFFFFFFFFFFFFFF'  => '65535',
          '0xFFFFFFFFFFFFFFFF' => '65535',
        }
        expectations.each { |val, exp| test_numeric_singleton('!UW', val, exp) }

        expectations = {
          '-1'                 => '-1',
          '0'                  => '0',
          '1'                  => '1',
          '0x100'              => '256',
          '0xFFF'              => '4095',
          '0xFFFF'             => '-1',
          '0xFFFFF'            => '-1',
          '0xFFFFFF'           => '-1',
          '0xFFFFFFF'          => '-1',
          '0xFFFFFFFF'         => '-1',
          '0xFFFFFFFFF'        => '-1',
          '0xFFFFFFFFFF'       => '-1',
          '0xFFFFFFFFFFF'      => '-1',
          '0xFFFFFFFFFFFF'     => '-1',
          '0xFFFFFFFFFFFFF'    => '-1',
          '0xFFFFFFFFFFFFFF'   => '-1',
          '0xFFFFFFFFFFFFFFF'  => '-1',
          '0xFFFFFFFFFFFFFFFF' => '-1',
        }
        expectations.each { |val, exp| test_numeric_singleton('!SW', val, exp) }

        expectations = {
          '-1'                 => '65535',
          '0'                  => '0',
          '1'                  => '1',
          '0x100'              => '256',
          '0xFFF'              => '4095',
          '0xFFFF'             => '65535',
          '0xFFFFF'            => '65535',
          '0xFFFFFF'           => '65535',
          '0xFFFFFFF'          => '65535',
          '0xFFFFFFFF'         => '65535',
          '0xFFFFFFFFF'        => '65535',
          '0xFFFFFFFFFF'       => '65535',
          '0xFFFFFFFFFFF'      => '65535',
          '0xFFFFFFFFFFFF'     => '65535',
          '0xFFFFFFFFFFFFF'    => '65535',
          '0xFFFFFFFFFFFFFF'   => '65535',
          '0xFFFFFFFFFFFFFFF'  => '65535',
          '0xFFFFFFFFFFFFFFFF' => '65535',
        }
        expectations.each { |val, exp| test_numeric_singleton('!ZW', val, exp) }

        expectations = {
          '-1'                 => '177777',
          '0'                  => '000000',
          '1'                  => '000001',
          '0x100'              => '000400',
          '0xFFF'              => '007777',
          '0xFFFF'             => '177777',
          '0xFFFFF'            => '177777',
          '0xFFFFFF'           => '177777',
          '0xFFFFFFF'          => '177777',
          '0xFFFFFFFF'         => '177777',
          '0xFFFFFFFFF'        => '177777',
          '0xFFFFFFFFFF'       => '177777',
          '0xFFFFFFFFFFF'      => '177777',
          '0xFFFFFFFFFFFF'     => '177777',
          '0xFFFFFFFFFFFFF'    => '177777',
          '0xFFFFFFFFFFFFFF'   => '177777',
          '0xFFFFFFFFFFFFFFF'  => '177777',
          '0xFFFFFFFFFFFFFFFF' => '177777',
        }
        expectations.each { |val, exp| test_numeric_singleton('!OW', val, exp) }

        expectations = {
          '-1'                 => 'FFFF',
          '0'                  => '0000',
          '1'                  => '0001',
          '0x100'              => '0100',
          '0xFFF'              => '0FFF',
          '0xFFFF'             => 'FFFF',
          '0xFFFFF'            => 'FFFF',
          '0xFFFFFF'           => 'FFFF',
          '0xFFFFFFF'          => 'FFFF',
          '0xFFFFFFFF'         => 'FFFF',
          '0xFFFFFFFFF'        => 'FFFF',
          '0xFFFFFFFFFF'       => 'FFFF',
          '0xFFFFFFFFFFF'      => 'FFFF',
          '0xFFFFFFFFFFFF'     => 'FFFF',
          '0xFFFFFFFFFFFFF'    => 'FFFF',
          '0xFFFFFFFFFFFFFF'   => 'FFFF',
          '0xFFFFFFFFFFFFFFF'  => 'FFFF',
          '0xFFFFFFFFFFFFFFFF' => 'FFFF',
        }
        expectations.each { |val, exp| test_numeric_singleton('!XW', val, exp) }

        #
        # Now the 32-bit word effectors
        #
        expectations = {
          '-1'                 => '4294967295',
          '0'                  => '0',
          '1'                  => '1',
          '0x100'              => '256',
          '0xFFF'              => '4095',
          '0xFFFF'             => '65535',
          '0xFFFFF'            => '1048575',
          '0xFFFFFF'           => '16777215',
          '0xFFFFFFF'          => '268435455',
          '0xFFFFFFFF'         => '4294967295',
          '0xFFFFFFFFF'        => '4294967295',
          '0xFFFFFFFFFF'       => '4294967295',
          '0xFFFFFFFFFFF'      => '4294967295',
          '0xFFFFFFFFFFFF'     => '4294967295',
          '0xFFFFFFFFFFFFF'    => '4294967295',
          '0xFFFFFFFFFFFFFF'   => '4294967295',
          '0xFFFFFFFFFFFFFFF'  => '4294967295',
          '0xFFFFFFFFFFFFFFFF' => '4294967295',
        }
        expectations.each { |val, exp| test_numeric_singleton('!UL', val, exp) }

        expectations = {
          '-1'                 => '-1',
          '0'                  => '0',
          '1'                  => '1',
          '0x100'              => '256',
          '0xFFF'              => '4095',
          '0xFFFF'             => '65535',
          '0xFFFFF'            => '1048575',
          '0xFFFFFF'           => '16777215',
          '0xFFFFFFF'          => '268435455',
          '0xFFFFFFFF'         => '-1',
          '0xFFFFFFFFF'        => '-1',
          '0xFFFFFFFFFF'       => '-1',
          '0xFFFFFFFFFFF'      => '-1',
          '0xFFFFFFFFFFFF'     => '-1',
          '0xFFFFFFFFFFFFF'    => '-1',
          '0xFFFFFFFFFFFFFF'   => '-1',
          '0xFFFFFFFFFFFFFFF'  => '-1',
          '0xFFFFFFFFFFFFFFFF' => '-1',
        }
        expectations.each { |val, exp| test_numeric_singleton('!SL', val, exp) }

        expectations = {
          '-1'                 => '4294967295',
          '0'                  => '0',
          '1'                  => '1',
          '0x100'              => '256',
          '0xFFF'              => '4095',
          '0xFFFF'             => '65535',
          '0xFFFFF'            => '1048575',
          '0xFFFFFF'           => '16777215',
          '0xFFFFFFF'          => '268435455',
          '0xFFFFFFFF'         => '4294967295',
          '0xFFFFFFFFF'        => '4294967295',
          '0xFFFFFFFFFF'       => '4294967295',
          '0xFFFFFFFFFFF'      => '4294967295',
          '0xFFFFFFFFFFFF'     => '4294967295',
          '0xFFFFFFFFFFFFF'    => '4294967295',
          '0xFFFFFFFFFFFFFF'   => '4294967295',
          '0xFFFFFFFFFFFFFFF'  => '4294967295',
          '0xFFFFFFFFFFFFFFFF' => '4294967295',
        }
        expectations.each { |val, exp| test_numeric_singleton('!ZL', val, exp) }

        expectations = {
          '-1'                 => '37777777777',
          '0'                  => '00000000000',
          '1'                  => '00000000001',
          '0x100'              => '00000000400',
          '0xFFF'              => '00000007777',
          '0xFFFF'             => '00000177777',
          '0xFFFFF'            => '00003777777',
          '0xFFFFFF'           => '00077777777',
          '0xFFFFFFF'          => '01777777777',
          '0xFFFFFFFF'         => '37777777777',
          '0xFFFFFFFFF'        => '37777777777',
          '0xFFFFFFFFFF'       => '37777777777',
          '0xFFFFFFFFFFF'      => '37777777777',
          '0xFFFFFFFFFFFF'     => '37777777777',
          '0xFFFFFFFFFFFFF'    => '37777777777',
          '0xFFFFFFFFFFFFFF'   => '37777777777',
          '0xFFFFFFFFFFFFFFF'  => '37777777777',
          '0xFFFFFFFFFFFFFFFF' => '37777777777',
        }
        expectations.each { |val, exp| test_numeric_singleton('!OL', val, exp) }

        expectations = {
          '-1'                 => 'FFFFFFFF',
          '0'                  => '00000000',
          '1'                  => '00000001',
          '0x100'              => '00000100',
          '0xFFF'              => '00000FFF',
          '0xFFFF'             => '0000FFFF',
          '0xFFFFF'            => '000FFFFF',
          '0xFFFFFF'           => '00FFFFFF',
          '0xFFFFFFF'          => '0FFFFFFF',
          '0xFFFFFFFF'         => 'FFFFFFFF',
          '0xFFFFFFFFF'        => 'FFFFFFFF',
          '0xFFFFFFFFFF'       => 'FFFFFFFF',
          '0xFFFFFFFFFFF'      => 'FFFFFFFF',
          '0xFFFFFFFFFFFF'     => 'FFFFFFFF',
          '0xFFFFFFFFFFFFF'    => 'FFFFFFFF',
          '0xFFFFFFFFFFFFFF'   => 'FFFFFFFF',
          '0xFFFFFFFFFFFFFFF'  => 'FFFFFFFF',
          '0xFFFFFFFFFFFFFFFF' => 'FFFFFFFF',
        }
        expectations.each { |val, exp| test_numeric_singleton('!XL', val, exp) }

        #
        # Now the 64-bit word effectors
        #
        expectations = {
          '-1'                 => '18446744073709551615',
          '0'                  => '0',
          '1'                  => '1',
          '0x100'              => '256',
          '0xFFF'              => '4095',
          '0xFFFF'             => '65535',
          '0xFFFFF'            => '1048575',
          '0xFFFFFF'           => '16777215',
          '0xFFFFFFF'          => '268435455',
          '0xFFFFFFFF'         => '4294967295',
          '0xFFFFFFFFF'        => '68719476735',
          '0xFFFFFFFFFF'       => '1099511627775',
          '0xFFFFFFFFFFF'      => '17592186044415',
          '0xFFFFFFFFFFFF'     => '281474976710655',
          '0xFFFFFFFFFFFFF'    => '4503599627370495',
          '0xFFFFFFFFFFFFFF'   => '72057594037927935',
          '0xFFFFFFFFFFFFFFF'  => '1152921504606846975',
          '0xFFFFFFFFFFFFFFFF' => '18446744073709551615',
        }
        expectations.each { |val, exp| test_numeric_singleton('!UQ', val, exp) }

        expectations = {
          '-1'                 => '-1',
          '0'                  => '0',
          '1'                  => '1',
          '0x100'              => '256',
          '0xFFF'              => '4095',
          '0xFFFF'             => '65535',
          '0xFFFFF'            => '1048575',
          '0xFFFFFF'           => '16777215',
          '0xFFFFFFF'          => '268435455',
          '0xFFFFFFFF'         => '4294967295',
          '0xFFFFFFFFF'        => '68719476735',
          '0xFFFFFFFFFF'       => '1099511627775',
          '0xFFFFFFFFFFF'      => '17592186044415',
          '0xFFFFFFFFFFFF'     => '281474976710655',
          '0xFFFFFFFFFFFFF'    => '4503599627370495',
          '0xFFFFFFFFFFFFFF'   => '72057594037927935',
          '0xFFFFFFFFFFFFFFF'  => '1152921504606846975',
          '0xFFFFFFFFFFFFFFFF' => '-1',
        }
        expectations.each { |val, exp| test_numeric_singleton('!SQ', val, exp) }

        expectations = {
          '-1'                 => '18446744073709551615',
          '0'                  => '0',
          '1'                  => '1',
          '0x100'              => '256',
          '0xFFF'              => '4095',
          '0xFFFF'             => '65535',
          '0xFFFFF'            => '1048575',
          '0xFFFFFF'           => '16777215',
          '0xFFFFFFF'          => '268435455',
          '0xFFFFFFFF'         => '4294967295',
          '0xFFFFFFFFF'        => '68719476735',
          '0xFFFFFFFFFF'       => '1099511627775',
          '0xFFFFFFFFFFF'      => '17592186044415',
          '0xFFFFFFFFFFFF'     => '281474976710655',
          '0xFFFFFFFFFFFFF'    => '4503599627370495',
          '0xFFFFFFFFFFFFFF'   => '72057594037927935',
          '0xFFFFFFFFFFFFFFF'  => '1152921504606846975',
          '0xFFFFFFFFFFFFFFFF' => '18446744073709551615',
        }
        expectations.each { |val, exp| test_numeric_singleton('!ZQ', val, exp) }

        expectations = {
          '-1'                 => '1777777777777777777777',
          '0'                  => '0000000000000000000000',
          '1'                  => '0000000000000000000001',
          '0x100'              => '0000000000000000000400',
          '0xFFF'              => '0000000000000000007777',
          '0xFFFF'             => '0000000000000000177777',
          '0xFFFFF'            => '0000000000000003777777',
          '0xFFFFFF'           => '0000000000000077777777',
          '0xFFFFFFF'          => '0000000000001777777777',
          '0xFFFFFFFF'         => '0000000000037777777777',
          '0xFFFFFFFFF'        => '0000000000777777777777',
          '0xFFFFFFFFFF'       => '0000000017777777777777',
          '0xFFFFFFFFFFF'      => '0000000377777777777777',
          '0xFFFFFFFFFFFF'     => '0000007777777777777777',
          '0xFFFFFFFFFFFFF'    => '0000177777777777777777',
          '0xFFFFFFFFFFFFFF'   => '0003777777777777777777',
          '0xFFFFFFFFFFFFFFF'  => '0077777777777777777777',
          '0xFFFFFFFFFFFFFFFF' => '1777777777777777777777',
        }
        expectations.each { |val, exp| test_numeric_singleton('!OQ', val, exp) }

        expectations = {
          '-1'                 => 'FFFFFFFFFFFFFFFF',
          '0'                  => '0000000000000000',
          '1'                  => '0000000000000001',
          '0x100'              => '0000000000000100',
          '0xFFF'              => '0000000000000FFF',
          '0xFFFF'             => '000000000000FFFF',
          '0xFFFFF'            => '00000000000FFFFF',
          '0xFFFFFF'           => '0000000000FFFFFF',
          '0xFFFFFFF'          => '000000000FFFFFFF',
          '0xFFFFFFFF'         => '00000000FFFFFFFF',
          '0xFFFFFFFFF'        => '0000000FFFFFFFFF',
          '0xFFFFFFFFFF'       => '000000FFFFFFFFFF',
          '0xFFFFFFFFFFF'      => '00000FFFFFFFFFFF',
          '0xFFFFFFFFFFFF'     => '0000FFFFFFFFFFFF',
          '0xFFFFFFFFFFFFF'    => '000FFFFFFFFFFFFF',
          '0xFFFFFFFFFFFFFF'   => '00FFFFFFFFFFFFFF',
          '0xFFFFFFFFFFFFFFF'  => '0FFFFFFFFFFFFFFF',
          '0xFFFFFFFFFFFFFFFF' => 'FFFFFFFFFFFFFFFF',
        }
        expectations.each { |val, exp| test_numeric_singleton('!XQ', val, exp) }
      end                       # def test_004_unsized()

      def test_003_strings()
        testData = "A\001b\002C\003d\004E\005f\006G" +
          "\007h\010I\011j\012K\013l\014M\015n"
        dataLen = testData.length

        assert_equal(':' + testData + ':',
                     FTO.new(':!AS:', testData).format,
                     "Testing :!AS:[0,#{dataLen}]")
        assert_equal(':' + testData[0,5] + ':',
                     FTO.new(':!5AS:', testData).format,
                     "Testing :!5AS:[0,#{dataLen}]")
        assert_equal(':' + testData[0,5] + (' ' * 5) + ':',
                     FTO.new(':!10AS:', testData[0,5]).format,
                     "Testing :!10AS:[0,5]")
        assert_equal(':' + testData[0,5] + ':',
                     FTO.new(':!5AS:', testData[0,5]).format,
                     "Testing :!5AS:[0,5]")

        assert_equal(':A.b.C.d.E.f.G.h.I.j.K.l.M.n:',
                     FTO.new(':!AN:', testData).format,
                     "Testing :!AN:[0,#{dataLen}]")
        assert_equal(':A.b.C:',
                     FTO.new(':!5AN:', testData).format,
                     "Testing :!5AN:[0,#{dataLen}]")
        assert_equal(':A.b.C     :',
                     FTO.new(':!10AN:', testData[0,5]).format,
                     "Testing :!10AN:[0,5]")
        assert_equal(':A.b.C:',
                     FTO.new(':!5AN:', testData[0,5]).format,
                     "Testing :!5AN:[0,5]")

        assert_equal(':' + testData[0,10] + ':',
                     FTO.new(':!AD:', 10, testData).format,
                     "Testing :!AD:10,[0,#{dataLen}]")
        assert_equal(':' + testData[0,5] + ':',
                     FTO.new(':!5AD:', 10, testData).format,
                     "Testing :!5AD:10,[0,#{dataLen}]")
        assert_equal(':' + testData[0,5] + ("\000" * 5) + ':',
                     FTO.new(':!10AD:', 10, testData[0,5]).format,
                     "Testing :!10AD:10,[0,5]")
        assert_equal(':' + testData[0,5] + ("\000" * 5) + ':',
                     FTO.new(':!AD:', 10, testData[0,5]).format,
                     "Testing :!AD:10,[0,5]")

        assert_equal(':A.b.C.d.E.:',
                     FTO.new(':!AF:', 10, testData).format,
                     "Testing :!AF:10,[0,#{dataLen}]")
        assert_equal(':A.b.C:',
                     FTO.new(':!5AF:', 10, testData).format,
                     "Testing :!5AF:10,[0,#{dataLen}]")
        assert_equal(':A.b.C.....:',
                     FTO.new(':!10AF:', 10, testData[0,5]).format,
                     "Testing :!10AF:10,[0,5]")
        assert_equal(':A.b.C.....:',
                     FTO.new(':!AF:', 10, testData[0,5]).format,
                     "Testing :!AF:10,[0,5]")

      end                       # def test_005_strings()

      def test_004_fixedWidth()
        test_data = '1234567890'
        assert_equal(test_data,
                     FTO.new('!10<!AS!>', test_data).format,
                     'Testing :!10<!AS!>:10');
        assert_equal('     ' + test_data,
                     FTO.new('!15<!AS!>', test_data).format,
                     'Testing :!15<!AS!>:10');
        assert_equal('67890',
                     FTO.new('!5<!AS!>', test_data).format,
                     'Testing :!5<!AS!>:10');

      end                       # def test_002_fixedWidth()

      #
      # Test that the recursion does by the Fixed Window effector function
      # doesn't b0rk the argument list.
      #
      def test_005_fixedWidthArguments()
        test_data = 'abc'
        assert_equal('abc-abc-abc',
                     FTO.new('!AS-!-!3<!AS!>-!-!AS', test_data).format,
                     'Testing :!AS-!-!3<!AS!>-!-!AS:');
        assert_equal('abc-abc-abc',
                     FTO.new('!AS-!3<!-!AS!>-!-!AS', test_data).format,
                     'Testing :!AS-!3<!-!AS!>-!-!AS:');
        #debugger
        assert_equal('1-abc-3', 
                     FTO.new('!UL-!3<!AS!>-!UL', 1, test_data, 3).format,
                     'Testing :!AS-!3<!-!AS!>-!-!AS:');

      end                       # def test_003_fixedWidthArguments

      def test_006_datetime()
        #
        # @TODO: Test passing 0 for the time
        #
        # Our test time is 2012-02-29 14:15:16
        #
        t = Time.mktime(2012, 2, 29, 14, 15, 16)
        assert_equal(':2012-02-29 14:15:16:',
                     FTO.new(':!%T(%Y-%m-%d %H:%M:%S!):', t).format,
                     'Testing :!%T(%Y-%m-%d %H:%M:%S!):')

        assert_equal(':2012-02-29:',
                     FTO.new(':!%T(%Y-%m-%d!):', t).format,
                     'Testing :!%T(%Y-%m-%d!):')

        assert_equal(':2012-02-29:',
                     FTO.new(':!10%T(%Y-%m-%d %H:%M:%S!):', t).format,
                     'Testing :!10%T(%Y-%m-%d %H:%M:%S!):')

        assert_equal(':2012-02-29     :',
                     FTO.new(':!15%T(%Y-%m-%d!):', t).format,
                     'Testing :!15%T(%Y-%m-%d!):')

      end                       # def test_006_datetime()

      def test_007_plurals()
        assert_equal('I have -1 boats',
                     FTO.new('I have !SB boat!%S', -1).format)
        assert_equal('I HAVE -1 BOATS',
                     FTO.new('I HAVE !SB BOAT!%S', -1).format)
        assert_equal('I have 0 boats',
                     FTO.new('I have !SB boat!%S', 0).format)
        assert_equal('I HAVE 0 BOATS',
                     FTO.new('I HAVE !SB BOAT!%S', 0).format)
        assert_equal('I have 1 boat',
                     FTO.new('I have !SB boat!%S', 1).format)
        assert_equal('I HAVE 1 BOAT',
                     FTO.new('I HAVE !SB BOAT!%S', 1).format)
        assert_equal('I have 2 boats',
                     FTO.new('I have !SB boat!%S', 2).format)
        assert_equal('I HAVE 2 BOATS',
                     FTO.new('I HAVE !SB BOAT!%S', 2).format)
        assert_equal('-1 boats are cool',
                     FTO.new('!SB boat!%S !%is cool', -1).format)
        assert_equal('-1 BOATS ARE COOL',
                     FTO.new('!SB BOAT!%S !%IS COOL', -1).format)
        assert_equal('0 boats are cool',
                     FTO.new('!SB boat!%S !%is cool', 0).format)
        assert_equal('0 BOATS ARE COOL',
                     FTO.new('!SB BOAT!%S !%IS COOL', 0).format)
        assert_equal('1 boat is cool',
                     FTO.new('!SB boat!%S !%is cool', 1).format)
        assert_equal('1 BOAT IS COOL',
                     FTO.new('!SB BOAT!%S !%IS COOL', 1).format)
        assert_equal('2 boats are cool',
                     FTO.new('!SB boat!%S !%is cool', 2).format)
        assert_equal('2 BOATS ARE COOL',
                     FTO.new('!SB BOAT!%S !%IS COOL', 2).format)

      end                       # def test_007_plurals()

      #
      # Test the integer-in-arbitrary-radix effector:
      #   !@nR, !@0nR, !@#R, !@0#R
      #   !@nr, !@0nr, !@#r, !@0#r
      #
      def test_008_radix()
        36.times do |radix|
          next if (radix < 2)

          %w(r R).each do |rsig|
            expected = ':' + 100.to_s(radix) + ':'
            expected.upcase! if (rsig.eql?('R'))
            format = ":!@#{radix.to_s}#{rsig}:"
            result = FTO.new(format, 100).format
            assert_equal(expected,
                         result,
                         "Testing #{format}")

            expected = ':' + 100.to_s(radix) + ':'
            expected.upcase! if (rsig.eql?('R'))
            format = ":!@0#{radix.to_s}#{rsig}:"
            result = FTO.new(format, 100).format
            assert_equal(expected,
                         result,
                         "Testing #{format}")

            expected = 100.to_s(radix)
            expected = ':' + ('0' * (10 - expected.length)) + expected + ':'
            expected.upcase! if (rsig.eql?('R'))
            format = ":!10@0#{radix}#{rsig}:"
            result = FTO.new(format, 100).format
            assert_equal(expected,
                         result,
                         "Testing #{format}")

            #
            # Now the fun ones.. specify the radix in the argument list.
            #
            expected = ':' + 100.to_s(radix) + ':'
            expected.upcase! if (rsig.eql?('R'))
            format = ":!@##{rsig}:"
            result = FTO.new(format, radix, 100).format
            assert_equal(expected,
                         result,
                         "Testing #{format}")

            expected = ':' + 100.to_s(radix) + ':'
            expected.upcase! if (rsig.eql?('R'))
            format = ":!@0##{rsig}:"
            result = FTO.new(format, radix, 100).format
            assert_equal(expected,
                         result,
                         "Testing #{format}")

            expected = 100.to_s(radix)
            expected = ':' + ('0' * (10 - expected.length)) + expected + ':'
            expected.upcase! if (rsig.eql?('R'))
            format = ":!10@0##{rsig}:"
            result = FTO.new(format, radix, 100).format
            assert_equal(expected,
                         result,
                         "Testing #{format}")
          end
        end
      end                       # def test_008_radix()

      #
      # Test floating-point effectors
      #
      # @TODO since the exact syntax isn't decided yet..
      #
      def test_009_floats
      end                       # def test_009_floats

    end                         # class Test_FTO

  end                           # module Tests

end                             # module FormatText
