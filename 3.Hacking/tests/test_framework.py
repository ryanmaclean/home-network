#!/usr/bin/env python


"""
Testing of "Ansible Testing Framework" itself.
   Craig J Perry <craigp84@gmail.com>
"""


import unittest
from StringIO import StringIO
from tests import FileSystemAssertsMixin, AnsiblePlayTestCase


class TestFileSystemAssertsMixin(unittest.TestCase, FileSystemAssertsMixin):

    def test_file_exists(self):
        self.assertFileExists(__file__)

    def test_file_doesnt_exist(self):
        self.assertFileNotExists("foo")

    def test_file_contains(self):
        self.assertFileContains("/etc/passwd", 4, "root")
        self.assertFileContains("/etc/passwd", 1, "^root")

    def test_file_doesnt_contain(self):
        self.assertFileDoesntContain("/etc/passwd", "DonkeyKongRacer")


class TestAnsiblePlayTestCase(AnsiblePlayTestCase):

    def test_can_invoke_playbook(self):
        logfile = StringIO()
        self.play("TestAnsiblePlayTestCase.yml", logfile)
        logfile.seek(0)
        self.assertIn('ok: [localhost] => {"msg": "Hello, World!"}', logfile.read())


if __name__ == '__main__':
    unittest.main()

