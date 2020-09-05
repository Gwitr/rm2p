# rm2p
## General
A module designed to read Ruby marshal files

This module contains exposes 2 important objects:
* The unmarshal function
* The RubyObject type

## Supported file formats
Any file with data created by Marshal.load()

RXDATA files from RPGMaker XP

## Documentation
### unmarshal(path)
Arguments:
* path - a path to a file that contains a marshaled Ruby object

Returns:
* A list
* An integer
* A string
* A RubyObject instance

Throws:
* FileNotFoundError - Ruby interpreter not installed
* RuntimeError - An unknown error occured, perhaps there's something wrong with the supplied file

### class RubyObject()
A generic ruby object type.

#### rclass
Contains the ruby class name of the object, as a string.

#### \_\_repr\_\_()
Arguments:
* N/A

Returns:
* A string

Throws:
* N/A

Returns a ruby-like representation of an object.

Example:
```python
>>> obj = unmarshal(filepath)
>>> obj
#<RPG::Map:0x00000000951fa8b7>
```