
# Word count tool

This is the first challenge in the coding challenges series. The tool can count number of bytes, words, lines and characters.


## Installation

Download the contents and open them in a terminal window.

### To parse a single file

**Parameters**:

* -c - Count the number of bytes
* -l - Count the number of lines
* -w - Count the number of words
* -m - Count the number of characters
* input file path - Pass the file name to be parsed
* content - Pass a string content directly

If no option is provided the tool counts the number of lines, words and bytes

```
swift run wc test1.txt
```

```
swift run wc -ml test1.txt
```