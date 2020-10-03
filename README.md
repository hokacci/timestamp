# Timestamp

## What is this?

Do you have a log file?  
Does it have UNIX timestamp field?  
Does it make sense?  
Is the timestamp precision sec, or milli sec, or ...?  
Does the timestamp include decimal separator, or does not?

There are some annoying problems with timestamp expression.😭

This tool solves this problem ad hoc and convert them to human-readable expression.🎉

```
Usage: timestamp [OPTION]... [FILE]
Convert all UNIX timestamps in text to human-readable string ad hoc.

With no FILE, or when FILE is -, read standard input.

  -c, --check       Show what conversion happens

  -q, --quote       Quote output string
  -i, --iso         Use ISO 8601 format
  -u, --utc         Use UTC Time Zone (By default local time is used)

  -m, --milli       Use milli precision
  -M, --Micro       Use micro precision
  -n, --nano        Use nano precision

  -h, --help        Display this help and exit

This program uses ad hoc method to find Unix timestamp.
We highly recommend that you should check the conversion first with -c option.
```

## Install

`timestamp.pl` is a perl script.  
You can install this, for example,

### Linux

```
sudo install ./timestamp.pl /usr/local/bin/timestamp
```

### Windows

If you don't have Perl, install Perl in the first place.  
If you have Git for Windows, you already have.

Create file `timestamp.cmd` and write the following (for example) to it and add the path to PATH environment variable.

```cmd
@"C:\Program Files\Git\usr\bin\perl.exe" "timestamp.pl" %*
```

## Examples

```
$ cat test.txt
[1600701105] Something happens.
---
[1600801105123] Something else.
---
[1600901105123456] And more.
---
[1601001105123456789] More and more.
---
[1601101105.123456] There are various formats.
---
{"start": 1600701105, "end": 1601201105}
```

```
$ timestamp test.txt
[2020-09-22 00:11:45] Something happens.
---
[2020-09-23 03:58:25] Something else.
---
[2020-09-24 07:45:05] And more.
---
[2020-09-25 11:31:45] More and more.
---
[2020-09-26 15:18:25] There are various formats.
---
{"start": 2020-09-22 00:11:45, "end": 2020-09-27 19:05:05}
```

```
$ timestamp -q -i -M -u test.txt
["2020-09-21T15:11:45.000000Z"] Something happens.
---
["2020-09-22T18:58:25.123000Z"] Something else.
---
["2020-09-23T22:45:05.123456Z"] And more.
---
["2020-09-25T02:31:45.123456Z"] More and more.
---
["2020-09-26T06:18:25.123456Z"] There are various formats.
---
{"start": "2020-09-21T15:11:45.000000Z", "end": "2020-09-27T10:05:05.000000Z"}
```

```
$ timestamp -c -q test.txt 
[1600701105 => "2020-09-22 00:11:45"] Something happens.
---
[1600801105123 => "2020-09-23 03:58:25"] Something else.
---
[1600901105123456 => "2020-09-24 07:45:05"] And more.
---
[1601001105123456789 => "2020-09-25 11:31:45"] More and more.
---
[1601101105.123456 => "2020-09-26 15:18:25"] There are various formats.
---
{"start": 1600701105 => "2020-09-22 00:11:45", "end": 1601201105 => "2020-09-27 19:05:05"}
```

## Web Interface

If you are not familiar with command line tool, you can use web app version.  
[timestamp string converter](https://www.yhoka.com/app/timestamp-string-converter/) is implemented with Javascript.  
Note that there are some differences between them.

## Why Perl?

According to [Stack Overflow Developer Survey 2020](https://insights.stackoverflow.com/survey/2020#technology-most-loved-dreaded-and-wanted-languages-dreaded), Perl is the third most dreaded programming language.

It may seem strange that I implement this tool with Perl in 2020.

But there are good reasons for this.


### 1. This tool uses ad hoc method

This means some users will want to modify the script and add their special logic to it.  
If this program were implemented with compilation languages, like C++ or Go, users would have to start with development environment setup, for example, installing compilers.  
In many cases, it is thought to be too hard for users.

### 2. Perl is preinstalled in many OS

There are many script languages.  
Among them, Perl is old enough and many OS has Perl by default.  
This means users needn't install any additional software to modify the script.  
Python will be a good alternative.  
However, Perl is more common than Python.  
For example, Windows users do not have both by default. But [Git for Windows](https://gitforwindows.org/) comes with Perl and many developers (who want to check timestamp) are thought to use Git and already have Perl. Python does not.

### 3. Perl is better than Shell Script

This script can be implemented with bash, sed, awk, time commands.  
However, shell script can be easily complicated by use of PIPEs and temporary texts.  
Perl script is also known to be easily complicated. But better than shell script.  
They say Perl is good for text processing and this tools is for text processing.  
So, I think Perl is the best language to implement this tool.

## LICENSE

This software is released under the MIT License, see LICENSE.txt.
