#   Copyright (c) 2016, Xilinx, Inc.
#   All rights reserved.
# 
#   Redistribution and use in source and binary forms, with or without 
#   modification, are permitted provided that the following conditions are met:
#
#   1.  Redistributions of source code must retain the above copyright notice, 
#       this list of conditions and the following disclaimer.
#
#   2.  Redistributions in binary form must reproduce the above copyright 
#       notice, this list of conditions and the following disclaimer in the 
#       documentation and/or other materials provided with the distribution.
#
#   3.  Neither the name of the copyright holder nor the names of its 
#       contributors may be used to endorse or promote products derived from 
#       this software without specific prior written permission.
#
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
#   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
#   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
#   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
#   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
#   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#   OR BUSINESS INTERRUPTION). HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
#   WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
#   OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
#   ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


import os
import pytest
from pynq import Overlay

__author__ = "Yun Rock Qu"
__copyright__ = "Copyright 2016, Xilinx"
__email__ = "pynq_support@xilinx.com"


ol1 = Overlay('base.bit')
ol2 = Overlay('base.bit')
ol3 = Overlay('interface.bit')


@pytest.mark.run(order=2)
def test_overlay():
    """Test whether the overlay is properly set.
    
    Each overlay has its own bitstream. Also need the corresponding ".tcl" 
    files to pass the tests.
    
    """
    global ol1, ol2, ol3
    
    ol1.download()
    assert 'base.bit' in ol1.bitfile_name, \
        'Bitstream is not in the overlay.'
    assert len(ol1.ip_dict) > 0,\
        'Overlay gets empty IP dictionary.'
    assert len(ol1.gpio_dict) > 0,\
        'Overlay gets empty GPIO dictionary.'
    assert ol1.ip_dict['mb_bram_ctrl_1']['phys_addr'] == \
        int('0x40000000', 16), 'Overlay gets wrong IP base address.'
    assert ol1.ip_dict['mb_bram_ctrl_1']['addr_range'] == \
        int('0x10000', 16), 'Overlay gets wrong IP address range.'
    for i in ol1.ip_dict:
        assert ol1.ip_dict[i]['state'] is None,\
            'Overlay gets wrong IP state.'
        # Set "TEST" for IP states
        ol1.ip_dict[i]['state'] = "TEST"
    for i in ol1.gpio_dict:
        assert ol1.gpio_dict[i]['state'] is None, \
            'Overlay gets wrong GPIO state.'
        # Set "TEST" for GPIO states
        ol1.gpio_dict[i]['state'] = "TEST"
    ol1.reset()
    for i in ol1.ip_dict:
        # "TEST" should have been cleared by reset()
        assert ol1.ip_dict[i]['state'] is None,\
            'Overlay cannot reset IP dictionary.'
    for i in ol1.gpio_dict:
        # "TEST" should have been cleared by reset()
        assert ol1.gpio_dict[i]['state'] is None,\
            'Overlay cannot reset GPIO dictionary.'

    ol2.download()
    assert 'base.bit' in ol2.bitfile_name, \
        'Bitstream is not in the overlay.'
    assert len(ol2.ip_dict) > 0, \
        'Overlay gets empty IP dictionary.'
    assert len(ol2.gpio_dict) > 0, \
        'Overlay gets empty GPIO dictionary.'
    assert ol2.ip_dict['mb_bram_ctrl_1']['phys_addr'] == \
        int('0x40000000', 16), 'Overlay gets wrong IP base address.'
    assert ol2.ip_dict['mb_bram_ctrl_1']['addr_range'] == \
        int('0x10000', 16), 'Overlay gets wrong IP address range.'
    for i in ol2.ip_dict:
        assert ol2.ip_dict[i]['state'] is None, \
            'Overlay gets wrong IP state.'
        # Set "TEST" for IP states
        ol2.ip_dict[i]['state'] = "TEST"
    for i in ol2.gpio_dict:
        assert ol2.gpio_dict[i]['state'] is None, \
            'Overlay gets wrong GPIO state.'
        # Set "TEST" for GPIO states
        ol2.gpio_dict[i]['state'] = "TEST"
    ol2.reset()
    for i in ol2.ip_dict:
        # "TEST" should have been cleared by reset()
        assert ol2.ip_dict[i]['state'] is None, \
            'Overlay cannot reset IP dictionary.'
    for i in ol2.gpio_dict:
        # "TEST" should have been cleared by reset()
        assert ol2.gpio_dict[i]['state'] is None, \
            'Overlay cannot reset GPIO dictionary.'

    ol3.download()
    assert 'interface.bit' in ol3.bitfile_name, \
        'Bitstream is not in the overlay.'
    assert len(ol3.ip_dict) > 0, \
        'Overlay gets empty IP dictionary.'
    assert len(ol3.gpio_dict) > 0, \
        'Overlay gets empty GPIO dictionary.'
    assert ol3.ip_dict['mb_bram_ctrl_1']['phys_addr'] == \
        int('0x40000000', 16), 'Overlay gets wrong IP base address.'
    assert ol3.ip_dict['mb_bram_ctrl_1']['addr_range'] == \
        int('0x10000', 16), 'Overlay gets wrong IP address range.'
    for i in ol3.ip_dict:
        assert ol3.ip_dict[i]['state'] is None, \
            'Overlay gets wrong IP state.'
        # Set "TEST" for IP states
        ol3.ip_dict[i][2] = "TEST"
    for i in ol3.gpio_dict:
        assert ol3.gpio_dict[i]['state'] is None, \
            'Overlay gets wrong GPIO state.'
        # Set "TEST" for GPIO states
        ol3.gpio_dict[i]['state'] = "TEST"
    ol3.reset()
    for i in ol3.ip_dict:
        # "TEST" should have been cleared by reset()
        assert ol3.ip_dict[i]['state'] is None, \
            'Overlay cannot reset IP dictionary.'
    for i in ol3.gpio_dict:
        # "TEST" should have been cleared by reset()
        assert ol3.gpio_dict[i]['state'] is None, \
            'Overlay cannot reset GPIO dictionary.'


@pytest.mark.run(order=10)
def test_overlay1():
    """Download the bitstream for the first overlay, and then test.
    
    Need the corresponding `*.tcl` file to pass the tests.
    
    """
    global ol1
    ol1.download()
    assert not ol1.bitstream.timestamp == '', \
        'Overlay 1 (base.bit) has an empty timestamp.'
    assert ol1.is_loaded(), \
        'Overlay 1 (base.bit) should be loaded.'


@pytest.mark.run(order=30)
def test_overlay2():
    """Change to another overlay, and then test.
    
    Need the corresponding `*.tcl` file to pass the tests.
    
    """
    global ol2
    ol2.download()
    assert not ol2.bitstream.timestamp == '', \
        'Overlay 2 (base.bit) has an empty timestamp.'
    assert ol2.is_loaded(), \
        'Overlay 2 (base.bit) should be loaded.'


@pytest.mark.run(order=39)
def test_overlay3():
    """Change to another overlay, and then test.

    Need the corresponding `*.tcl` file to pass the tests.

    """
    global ol3
    ol3.download()
    assert not ol3.bitstream.timestamp == '', \
        'Overlay 3 (interface.bit) has an empty timestamp.'
    assert ol3.is_loaded(), \
        'Overlay 3 (interface.bit) should be loaded.'


@pytest.mark.run(order=49)
def test_end():
    """Wrapping up by changing the overlay back.
    
    This is the last test to be performed.
    
    """
    global ol1, ol2, ol3
    ol1.download()
    assert not ol1.bitstream.timestamp == '', \
        'Overlay 1 (base.bit) has an empty timestamp.'
    assert ol1.is_loaded(), \
        'Overlay 1 (base.bit) should be loaded.'
    del ol1
    del ol2
    del ol3
