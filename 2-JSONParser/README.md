
# JSON Parser

This parser handles only the basic inputs from the coding challenges. It is not equipped to handle decimal numbers or such. That functionality is fairly easy to add.


## Installation

Download the contents and open them in a terminal window.

### To parse a single file

**Parameters**:

* -d - Enable debug prints
* fileName - Pass the relative file path of the file

```
swift run json-parser -d tests/step1/valid.json
```
### To run the unit test cases
```
chmod +x unit_test.sh
./unit_test.sh
```