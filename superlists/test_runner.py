from django.test.runner import DiscoverRunner
from unittest.runner import TextTestRunner, TextTestResult
from time import time


class TimedTextTestResult(TextTestResult):

    def __init__(self, *args, **kwargs):
        super(TimedTextTestResult, self).__init__(*args, **kwargs)
        self.clocks = dict()

    def startTest(self, test):
        self.clocks[test] = time()
        super(TextTestResult, self).startTest(test)
        if self.showAll:
            self.stream.write(self.getDescription(test))
            self.stream.write(" ... ")
            self.stream.flush()

    def addSuccess(self, test):
        super(TextTestResult, self).addSuccess(test)
        if self.showAll:
            self.stream.writeln("ok-dokey (%.6fs)" %
                                (time() - self.clocks[test]))
        elif self.dots:
            self.stream.write('.')
            self.stream.flush()


class TimedTextTestRunner(TextTestRunner):
    resultclass = TimedTextTestResult


class MyTestRunner(DiscoverRunner):
    test_runner = TimedTextTestRunner
