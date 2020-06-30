import numpy as np
from subprocess import PIPE, Popen

"""
# rmarshal
A module designed to read Ruby marshal files

This module contains exposes 2 important objects:
* The unmarshal function
* The RubyObject type

## unmarshal(path)
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

## RubyObject
A generic ruby object type.

### rclass
Contains the ruby class name of the object, as a string.

### __repr__()
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
#<RPG::Map:0x00000000951fa8b7>```
"""

class RubyObject():

    def __repr__(self):
        return "#<%s:0x%016x>" % (self.rclass, id(self))

SPECIAL_CLASS_MAP = {
    "FalseClass": (lambda x: False),
    "TrueClass": (lambda x: True),
    "Table": (lambda x: np.array(x.array))
}

def callruby(path):
    p = Popen(["ruby", "c:\\users\\gwitr\\desktop\\programming\\ruby\\extract_rxdata.rb", path], stdout=PIPE)
    return p.communicate()[0]

def _unserialize_obj(x, classname):
    # print(x[:128])
    i = 0
    n_of_elements = ""
    while x[i] != " ":
        n_of_elements += x[i]
        i += 1
    i += 1

    n_of_elements = int(n_of_elements)

    res = RubyObject()

    res.rclass = classname

    attrname = ""
    mode = "attrname"
    cnt = 0
    while cnt < n_of_elements:
        if mode == "attrname":
            if x[i] == " ":
                mode = "value"
            else:
                attrname += x[i]
            i += 1
        elif mode == "value":
            v, di = _unserialize(x[i:])
            i += di
            setattr(res, attrname[1:], v)
            attrname = ""
            cnt += 1
            mode = "attrname"

    if res.rclass in SPECIAL_CLASS_MAP:
        return SPECIAL_CLASS_MAP[res.rclass](res), i

    return res, i

def _unserialize(x):
    # print(x[:128])
    i = 0
    classname = ""
    while x[i] != " ":
        classname += x[i]
        i += 1
    i += 1

    # print(classname)
    if classname == "Integer":
        # print("int")
        res = ""
        # print(x[:128])
        while x[i] != " ":
            # print(x[i])
            res += x[i]
            i += 1
        i += 1
        # print(x[i:i+10])
        # print("=========")
        return int(res), i

    elif classname == "String":
        # print("str")
        l = ""
        while x[i] != " ":
            l += x[i]
            i += 1
        i += 1
        l = int(l)
        res = ""
        for _ in range(l):
            res += x[i]
            i += 1
        i += 1
        return res, i

    elif classname == "Array":
        # print("list")
        l = ""
        while x[i] != " ":
            l += x[i]
            i += 1
        i += 1
        l = int(l)

        res = []
        for _ in range(l):
            v, di = _unserialize(x[i:])
            res.append(v)
            i += di
            # i += 1
        # i += 1
        return res, i

    elif classname == "Hash":
        # print("dict")
        l = ""
        while x[i] != " ":
            l += x[i]
            i += 1
        i += 1
        l = int(l)

        res = {}
        attrname = ""
        mode = "attrname"
        cnt = 0
        while cnt < l:
            if mode == "attrname":
                # if x[i] == " ":
                #     mode = "value"
                # else:
                #     attrname += x[i]
                # print("KEY", x[i:i+100], "|", attrname)
                # i += 1
                v, di = _unserialize(x[i:])
                i += di
                i += 1
                attrname = v
                mode = "value"
            elif mode == "value":
                v, di = _unserialize(x[i:])
                # print("HASH VALUE", x[i:i+200], "|", v)
                # print(x[i:i+200])
                i += di
                # print(x[i:i+200])
                res[attrname] = v  # setattr(res, attrname[1:], v)
                attrname = ""
                cnt += 1
                mode = "attrname"
            # print("HASH %d LEFT" % (l - cnt))
        i += 1
        return res, i

    else:
        # print("object")
        res, di = _unserialize_obj(x[i:], classname)
        i += di
        i += 1
        return res, i

def unmarshal(path):
    res = callruby("D:\\Steam\\Steamapps\\common\\OneShot\\Data\\Map020.rxdata")
    if len(res) == 0:
        raise RuntimeError
    return _unserialize(res.decode("utf8"))[0]
