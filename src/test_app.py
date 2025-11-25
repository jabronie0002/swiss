import unittest
from utils import mirror_word

class TestMirrorFunction(unittest.TestCase):
    def test_mirror_word(self):
        self.assertEqual(mirror_word("Hello"), "OLLEh")
        self.assertEqual(mirror_word("123"), "321")
        self.assertEqual(mirror_word(""), "")

if __name__ == '__main__':
    unittest.main()
