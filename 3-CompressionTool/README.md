
# Compression Tool

This is the third challenge in the coding challenges series. The tool uses Huffman Encoding to compress the file and decompress the compressed file.


## Installation

Download the contents and open them in a terminal window.

### To parse a single file

**Parameters**:

* -d - Enable debug prints
* input file name - Pass the file name of the file to be compressed
* compressed file name - The name of the compressed output file
* uncompressed file name - Pass the output file name that contains the original content

```
swift run compress art_of_war.txt compressed.txt uncompressed.txt -d
```