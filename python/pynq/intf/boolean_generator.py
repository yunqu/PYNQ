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
import re
from pyeda.inter import exprvar
from pyeda.inter import expr2truthtable
from .intf_const import ARDUINO
from .intf_const import CMD_GENERATE_DEFAULT_BOOLEAN
from .intf_const import CMD_GENERATE_USER_BOOLEAN
from .intf import request_intf


__author__ = "Yun Rock Qu"
__copyright__ = "Copyright 2017, Xilinx"
__email__ = "pynq_support@xilinx.com"


IN_PINS = [['D0', 'D1', 'D2', 'D3'],
           ['D5', 'D6', 'D7', 'D8'],
           ['D10', 'D11', 'D12', 'D13'],
           ['A1', 'A2', 'A3', 'A4'],
           ['PB0', 'PB1', 'PB2', 'PB3']]
OUT_PINS = ['D4', 'D9', 'A0', 'A5']
LD_PINS = ['LD0', 'LD1', 'LD2', 'LD3', 'LD4', 'LD5']
ARDUINO_CFG_PROGRAM = "arduino_intf.bin"


class BooleanGenerator:
    """Class for the Combinational Function Generator.

    This class can implement any combinational function on user IO pins. A
    typical function implemented for a bank of 5 pins can be 4-input and
    1-output. However, by connecting pins across different banks, users can
    implement more complex functions with more input/output pins.

    Attributes
    ----------
    if_id : int
        The interface ID (ARDUINO).
    intf : _INTF
        INTF instance used by Arduino_CFG class.
    expr : str
        The boolean expression in string format.
    led : bool
        Whether LED is used to indicate output.
    verbose : bool
        Whether to show verbose message to users.

    """

    def __init__(self, if_id, expr=None, led=True, verbose=True):
        """Return a new Arduino_CFG object.

        For ARDUINO, the available input pins are data pins (D0-D13, A0-A5),
        the onboard push buttons (PB0-PB3). The available output pins are
        D4, D9, A0, A5, and the onboard LEDs (LD0-LD5).

        Bank 0:
        input 0 - 3: D0 - D3; output: D4/LD0.

        Bank 1:
        input 0 - 3: D5 - D8; output: D9/LD1.

        Bank 2:
        input 0 - 3: D10 - D13; output: A0/LD2.

        Bank 3:
        input 0 - 3: A1 - A4; output: A5/LD3.

        Bank 4:
        input 0 - 3: PB0 - PB3; output: LD4

        The input boolean expression can be of the following formats:
        (1) `D0 & D1 | D2`, or
        (2) `D4 = D0 & D1 | D2`.

        If no input boolean expression is specified, the default function
        implemented is `D0 & D1 & D2 & D3`.

        Note
        ----
        When LED is used as the output indicator, an LED on indicates the
        corresponding output is logic high.

        Parameters
        ----------
        if_id : int
            The interface ID (ARDUINO).
        expr : str
            The boolean expression in a string.
        led : bool
            Whether LED is used to indicate output; defaults to true.
        verbose : bool
            Whether to show verbose message to users.

        """
        if os.geteuid() != 0:
            raise EnvironmentError('Root permissions required.')
        if if_id not in [ARDUINO]:
            raise ValueError("No such INTF for Arduino interface.")

        self.if_id = if_id
        self.intf = request_intf(if_id, ARDUINO_CFG_PROGRAM)
        self.expr = expr
        self.led = led
        self.verbose = verbose

        if expr is None:
            self.intf.write_command(CMD_GENERATE_DEFAULT_BOOLEAN)
        else:
            self.bool_func(expr, led, verbose)

    def bool_func(self, expr, led=True, verbose=True):
        """Configure the CFG with new boolean expression or LED indicator.

        Implements boolean function at specified IO pins with optional led
        output.

        Parameters
        ----------
        expr : str
            The new boolean expression.
        led : bool
            Show boolean function output on onboard LED, defaults to true
        verbose : bool
            Whether to show verbose message to users.

        Returns
        -------
        None

        """
        if not isinstance(expr, str):
            raise TypeError("Boolean expression has to be a string.")

        self.expr = expr
        self.led = led
        self.verbose = verbose

        # parse boolean expression
        bank_out = None
        if "=" in expr:
            expr_out, expr_in = expr.split("=")
            expr_out = expr_out.strip()
            if expr_out in OUT_PINS:
                bank_out = OUT_PINS.index(expr_out)
            elif expr_out in LD_PINS:
                bank_out = LD_PINS.index(expr_out)
            else:
                raise ValueError("Invalid output pin.")
        else:
            expr_in = expr

        # parse the used pins
        pin_id = re.sub("\W+", " ", expr_in).strip().split(' ')
        bank_in = 0
        for b in range(5):
            if pin_id[0] in IN_PINS[b]:
                bank_in = b
                break
        if (bank_out is not None) and (bank_in != bank_out):
            raise ValueError("Invalid combination of IO pins.")

        # check whether pins are valid
        intersect = set(IN_PINS[bank_in]) & set(pin_id)
        if set(intersect) != set(pin_id):
            raise ValueError("Invalid combination of IO pins.")

        for i in IN_PINS[bank_in]:
            if i not in expr_in:
                expr_in = '(' + expr_in + '&' + i + \
                          ')|(' + expr_in + '&~' + i + ')'

        # map to truth table
        p0, p1, p2, p3 = map(exprvar, IN_PINS[bank_in])
        expr_p = expr_in

        if bank_in == 0:
            for i in range(4):
                expr_p = expr_p.replace('D' + str(i), 'p' + str(i))
        elif bank_in == 1:
            for i in range(4):
                expr_p = expr_p.replace('D' + str(i + 5), 'p' + str(i))
        elif bank_in == 2:
            for i in range(4):
                expr_p = expr_p.replace('D' + str(i + 10), 'p' + str(i))
        elif bank_in == 3:
            for i in range(4):
                expr_p = expr_p.replace('A' + str(i + 1), 'p' + str(i))
        else:
            for i in range(4):
                expr_p = expr_p.replace('PB' + str(i), 'p' + str(i))

        truth_table = expr2truthtable(eval(expr_p))
        if verbose:
            if led:
                print("Logic output mapped to {}".format(LD_PINS[bank_in]))
            if bank_in < 4:
                print("Logic output mapped to {}".format(OUT_PINS[bank_in]))
            print("Truth table:")
            print(truth_table)

        # parse truth table to send
        truth_list = str(truth_table).split("\n")
        truth_num = 0
        for i in range(16, 0, -1):
            truth_num = (truth_num << 1) + int(truth_list[i][-1])

        # construct the command word
        cmd_word = CMD_GENERATE_USER_BOOLEAN
        cmd_word |= (0x1 << (4 + bank_in))
        if led:
            cmd_word |= (0x1 << 12)

        self.intf.write_control([truth_num])
        self.intf.write_command(cmd_word)
