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


import numpy as np
import pytest
from pynq.intf.intf_const import OUTPUT_PIN_MAP
from pynq.intf.intf_const import OUTPUT_SAMPLE_SIZE
from pynq.intf import PatternAnalyzer
from pynq.intf.pattern_generator import _bitstring_to_int
from pynq.intf.pattern_generator import _wave_to_bitstring
from pynq.intf.pattern_generator import _int_to_sample


__author__ = "Yun Rock Qu"
__copyright__ = "Copyright 2016, Xilinx"
__email__ = "pynq_support@xilinx.com"


@pytest.mark.run(order=44)
def test_analyzer():
    """Test for the PatternAnalyzer class.
    
    Specify a stimulus group, and calculate the samples to be captured.
    Convert the samples back into wavelanes, and compare the wavelanes with
    the original wavelanes in the stimulus group. 
    
    """
    if_id = 3
    analyzer = PatternAnalyzer(if_id)

    stimulus_group = [
        {'name': 'clk0', 'pin': 'D0', 'wave': 'lh' * 64},
        {'name': 'clk1', 'pin': 'D1', 'wave': 'l.h.' * 32},
        {'name': 'clk2', 'pin': 'D2', 'wave': 'l...h...' * 16},
        {'name': 'clk3', 'pin': 'D3', 'wave': 'l.......h.......' * 8}]

    num_samples = 128
    temp_lanes = np.zeros((OUTPUT_SAMPLE_SIZE, num_samples),
                          dtype=np.uint8)
    for index, wavelane in enumerate(stimulus_group):
        pin_number = OUTPUT_PIN_MAP[wavelane['pin']]
        temp_lanes[pin_number] = _bitstring_to_int(
            _wave_to_bitstring(wavelane['wave']))

    temp_samples = temp_lanes.T.copy()
    src_samples = np.apply_along_axis(_int_to_sample, 1, temp_samples)

    dst_samples = src_samples.copy()
    analysis_group = analyzer.analyze(dst_samples)

    for wavelane1 in analysis_group:
        for wavelane0 in stimulus_group:
            if wavelane1['pin'] == wavelane0['pin']:
                assert wavelane1['wave'] == wavelane0['wave'], \
                    f"Analyzer returns wrong data on {wavelane1['pin']}."
