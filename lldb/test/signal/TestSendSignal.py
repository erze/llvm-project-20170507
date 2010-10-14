"""Test that lldb command 'process signal SIGUSR1' to send a signal to the inferior works."""

import os, time, signal
import unittest2
import lldb
from lldbtest import *

class SendSignalTestCase(TestBase):

    mydir = "signal"

    @unittest2.skipUnless(sys.platform.startswith("darwin"), "requires Darwin")
    def test_with_dsym_and_run_command(self):
        """Test that lldb command 'process signal SIGUSR1' sends a signal to the inferior process."""
        self.buildDsym()
        self.send_signal()

    def test_with_dwarf_and_run_command(self):
        """Test that lldb command 'process signal SIGUSR1' sends a signal to the inferior process."""
        self.buildDwarf()
        self.send_signal()

    def setUp(self):
        super(SendSignalTestCase, self).setUp()
        # Find the line number to break inside main().
        self.line = line_number('main.c', 'Put breakpoint here')

    def send_signal(self):
        """Test that lldb command 'process signal SIGUSR1' sends a signal to the inferior process."""

        exe = os.path.join(os.getcwd(), "a.out")
        self.runCmd("file " + exe, CURRENT_EXECUTABLE_SET)

        # Break inside the main() function and immediately send a signal to the inferior after resuming.
        self.expect("breakpoint set -f main.c -l %d" % self.line,
                    BREAKPOINT_CREATED,
            startstr = "Breakpoint created: 1: file ='main.c', line = %d, locations = 1" %
                        self.line)

        self.runCmd("run", RUN_SUCCEEDED)
        self.runCmd("thread backtrac")

        # The stop reason of the thread should be breakpoint.
        self.expect("thread list", STOPPED_DUE_TO_BREAKPOINT,
            substrs = ['state is Stopped',
                       'stop reason = breakpoint'])

        # The breakpoint should have a hit count of 1.
        self.expect("breakpoint list", BREAKPOINT_HIT_ONCE,
            substrs = [' resolved, hit count = 1'])

        self.runCmd("process status")
        output = self.res.GetOutput()
        pid = re.match("Process (.*) Stopped", output).group(1)

        # After resuming the process, immediately send a SIGUSR1 signal.
        self.dbg.SetAsync(True)
        self.runCmd("process continue")
        self.runCmd("process handle -n False -p True -s True SIGUSR1")
        #os.kill(int(pid), signal.SIGUSR1)
        self.runCmd("process signal SIGUSR1")

        time.sleep(1)
        self.dbg.SetAsync(False)
        self.expect("process status", STOPPED_DUE_TO_SIGNAL,
            startstr = "Process %s Stopped" % pid,
            substrs = ['stop reason = signal SIGUSR1'])
        self.expect("thread backtrace", STOPPED_DUE_TO_SIGNAL,
            substrs = ['stop reason = signal SIGUSR1'])


if __name__ == '__main__':
    import atexit
    lldb.SBDebugger.Initialize()
    atexit.register(lambda: lldb.SBDebugger.Terminate())
    unittest2.main()
