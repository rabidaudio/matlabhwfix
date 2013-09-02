matlabhwfix
===========

This is a short perl script I wrote back in Fall 2012. It goes through homework files
for Gatech's CS 1371 and makes sure they fit the requirements for the autograder.

This perl script reads uncompiled matlab scripts (commonly .m files), and looks
for problems that may arise with the Auto-Grader programs used by professors and
TA's at Georgia Tech. 

Written by Charles Knight <cknight7@gatech.edu>

IMPORTANT
========
This program does NOT do assignments for you or have any information about homework
assignments. You are totally allowed to use it in class. It isn't an error checker
or a test case program; instead, it looks for problems which are only an issue with
the GT Auto-Grader, but compile fine in MATLAB. I MAKE NO GUARANTEE THAT IT WILL CATCH
ALL ERRORS. I have tested every case I can think of, but that doesn't make it infallible.

Also note that this script is from several semsters ago, and may not check for everything
that you can't do with the autograder.

Features
========
* checks that you have suppressed the output of your lines (using semicolons)
* checks for functions you aren't allowed to use, e.g. `disp`
* lines that contain the words `REMOVE` or `TEST` in all caps will be commented out (for text code, etc)
* lines that contain the word `TODO` in all caps will raise a warning (in case you forgot to go back and fix something)


USING
=====
You can now scan an entire directory. Just do `perl mlhwfix.pl -d [my/homework/directory/]`

linux
-----
This was written for and tested on Linux, and nowhere else. Linux users should
be able to do `perl mlhwfix.pl [myfile.m]` from terminal. If that doesn't work, do a
`sudo chmod 755 mlhwfix.pl` first. 

Mac
---
Mac OSX users should be able to use this just fine, but be sure you install perl
first. After that, just do `perl mlhwfix.pl [myfile.m]` in a terminal.

Windows
-------
Windows users may be out of luck. You can look into Perl2Exe, a freeware program
online somewhere. I've never used it, so I don't know if it will work. You will also
need to change the 'system()' lines at the end of the program as directed, or else
the program will not be able to save your changes.


One last thing: if you end up using this regularly, let me know. I would love the
feedback. Good luck!
