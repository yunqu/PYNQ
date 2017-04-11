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


import pytest
from pynq import Overlay
from pynq.tests.util import user_answer_yes
from pynq.intf import BooleanGenerator


__author__ = "Yun Rock Qu"
__copyright__ = "Copyright 2016, Xilinx"
__email__ = "pynq_support@xilinx.com"


ol = Overlay('interface.bit')


@pytest.mark.run(order=45)
def test_bool_func_default():
    """Test for the BooleanGenerator class.
    
    The first test will test the default configuration. The default
    configuration for any group is AND.
    
    """
    if_id = 3
    bool_generator = BooleanGenerator(if_id, led=True, verbose=False)
    print(f'\nPress all the 4 push buttons on board.')
    assert user_answer_yes("RGB LED (LD4) on when pressing?"), \
        "Default configuration fails to show the AND output on RGBLED."
    del bool_generator


@pytest.mark.run(order=46)
def test_bool_func_custom():
    """Test for the BooleanGenerator class.

    The second test will test a customized configuration. An OR function is
    used as the example.

    """
    if_id = 3
    or_operation = 'PB0 | PB1 | PB2 | PB3'
    bool_generator = BooleanGenerator(if_id, expr=or_operation,
                                      led=True, verbose=False)
    print(f'\nPress any of the 4 push buttons on board.')
    assert user_answer_yes("RGB LED (LD4) on when pressing?"), \
        "Configuration fails to show the OR output on RGBLED."
    del bool_generator
    ol.reset()
