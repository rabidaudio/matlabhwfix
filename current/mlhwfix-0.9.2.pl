#!/usr/bin/perl
use strict;
######################
# VERSION 0.9.2
#
# This perl script reads uncompiled matlab scripts (commonly .m files), and looks
# for problems that may arise with the Auto-Grader programs used by professors and
# TA's at Georgia Tech. It isn't an error checker or a test case program; instead,
# it looks for problems which are only an issue with the GT Auto-Grader, but compile
# fine in MATLAB. I MAKE NO GUARANTEE THAT IT WILL CATCH ALL ERRORS. I have tested
# every case I can think of, but that doesn't make it infallible. 
# 
# Written by Charles Knight, cknight7@gatech.edu. If you find a bug or need help
# with the script, you can email me and I will try to help, but I make no guarantees
# that I will have time. Also, fixing problems may require you to send me your code,
# which would be a violation of the honor code, so you will have to wait until AFTER
# the second deadline has passed.
#
# USING
# This was written for and tested on Linux, and nowhere else. Linux users should
# be able to do `./mlhwfix.pl [myfile.m]` from terminal. If that doesn't work, do a
# `sudo chmod 755 mlhwfix.pl` first. 
# Mac OSX users should be able to use this just fine, but be sure you install perl
# first. After that, just do `perl mlhwfix.pl [myfile.m]` in a terminal (Linux users
# should be able to do this, too).
# Windows users may be out of luck. You can look into Perl2Exe, a freeware program
# online somewhere. I've never used it, so I don't know if it will work. You will also
# need to change the 'system()' lines at the end of the program as directed, or else
# the program will not be able to save your changes.
#
# One last thing: if you end up using this regularly, let me know. I would love the
# feedback. Good luck!
#######################
#  THIS PROGRAM LICENSED UNDER THE GNU GPL 3.0 LICENSE. SEE http://www.gnu.org/copyleft/gpl.html
#  EXCEPT FOR THE FOLLOWING CODE FROM http://www.devdaily.com/perl/edu/articles/pl010005 by alvin:
sub promptUser { my($prompt, $default)=@_; my $defaultValue = $default ? "[$default]" : ""; print "$prompt $defaultValue: "; chomp(my $input = <STDIN>); return $input ? $input : $default; }
######################
my $usage = "Usage: perl mlhwfix.pl [myhwfile.m] or perl mlhwfix.pl -d='[myhwdirectory]'";
(print $usage."\n" and exit) if(!$ARGV[0]);
my @MFILES;
my $dir = $ARGV[0];
if ($dir=~ m/^-d=/){
  $dir =~ s/^-d=//;
  print $dir."\n";
  opendir(DIR, $dir) or die "Couldn't open directory.\n";
  my @FILES= readdir(DIR) or die "Couldn't find files\n";
  foreach(@FILES){ if($_ =~ m/\.m$/){ print $_."\n"; push(@MFILES, "$dir/$_"); } }#WINDOWS USERS change / to \ here
}else{
  $MFILES[0]=$dir;
}
foreach(@MFILES){
my $file = "$_";
print "opening file: $file\n\n";
my $linenum=0;
my $changes=0;
my @problemlines;
my $writeline;
my @badwords=("clear", "clc", "input", "error", "figure", "disp", "fclose all");#ADD NEW badwords HERE
my @specfunc=("function", "if", "else", "end", "for", "while", "elseif", "case", "switch", "otherwise"); #ADD NEW SC-less functions HERE

open my $in,  '<',  "$file" or die "ERROR: Couldn't open file: $!. Is it in use by another program? Did you give me the uncompiled script?\n";
open my $out, '>', "$file.temp" or die "ERROR: Can't write temp file.\n";

while(<$in>){
  chomp();
  $linenum++;
  $writeline=$_;
  $writeline=~ s/^\s*\%/\%/;
 if (not $writeline =~ m/^\s*$/){
#--------comment section
  if ($writeline =~ m/^.*\%/){
#------------------check TODO
    if($writeline =~ m/TODO/){
       print "NOTICE: you have a TODO statement still in your code.\n\n";
       print "Line $linenum: $writeline\n\n";
       push(@problemlines, $linenum);
       my $resp = &promptUser("Do you want me to remove the TODO flag? (y/n/q)");
       if($resp =~ m/^q/){ die "Quitting.\n"; }
       elsif($resp =~ m/^y/){ $writeline =~ s/TODO//g; $changes++; }
    }
#------------------check REMOVE/TEST
    if(($writeline=~ m/REMOVE/ or $writeline =~ m/TEST/) and not($writeline =~ m/^\s*\%/)){
print "catch REMOVE/TEST";
      print "WARN: you have a REMOVE or TEST flag on this line.\n\n";
      print "Line $linenum: $writeline\n\n";
      push(@problemlines, $linenum);
      my $resp = &promptUser("Do you want me to comment out this line? (y/n/q)");
      if($resp =~ m/^q/){ die "Quitting.\n"; }
      elsif($resp =~ m/^y/){
        #$writeline =~ s/TEST//g;
        $writeline =~ s/REMOVE//g;
        $writeline = "\%AUTOREMOVED $writeline";
        $changes++;
      }
    }
  }
#--------command section
  my $firstword = $writeline;
  $firstword =~ s/^\s*//;
  $firstword =~ s/\s.*$//;
  $firstword =~ s/;//;
  $firstword =~ s/\(.*$//g;
  #$firstword =~ s/[:punc:]//;
  #print $firstword."\n";
  if (not $firstword =~ m/^\s*\%/){
#------------------check forbidden commands
    if (grep $_ eq $firstword, @badwords){
        print "ERROR: Found forbidden command: $_\n\n";
        print "Line $linenum: $writeline\n\n";
        push(@problemlines, $linenum);
        my $resp = &promptUser("Do you want me to remove the line? (y/n/q)");
        if($resp =~ m/^q/){ die "Quitting.\n";}
        elsif($resp =~ m/^y/){
          $writeline = "\%AUTOREMOVED $writeline";
          $changes++;
        }
    }
#------------------check semicolon
    if (grep $_ eq $firstword, @specfunc){ ; }#print "OK\n"; }
    else{
      my $command = $writeline;
      $command =~ s/\%.*//;
      if(not $command =~ m/^.*;/ and not $command =~ m/^\s*$/ ){
        print "ERROR: This line is missing a semicolon:\n\n";
        print "Line $linenum: $writeline\n\n";
        push(@problemlines, $linenum);
        my $resp = &promptUser("Do you want me to add one to this line? (y/n/q)");
        if($resp =~ m/^q/){
          die "Quitting.\n";
        }elsif($resp =~ m/^y/){
          if($writeline =~ m/\%/){
            $command =~ s/\s*\%.*//;
            $command = $command.";";
            $writeline =~ s/.*\%//;
            $command = "$command % $writeline";}
          else{
            $command =~ s/\s*$//;
            $command = $command.";";
          }
          $writeline = "$command  \%SEMICOLONADD";
          $changes++;
        }
      }
    }
  }
 }
print $out "$writeline\n";
}
close($in); close($out);
print "\n\nFound problems on lines: ";
my $i=0; while($i<=$#problemlines){print "@problemlines[$i], "; $i++;}
print "\nMade a total of $changes changes.\n";
if($changes==0){
  system("rm '$file.temp'");# NOTE: if you are on Windows, change 'rm' to 'del' !
}else{
   my $resp = &promptUser("Do you want to overwrite the file and save these changes? (y,n,q)");
   if($resp =~ m/^q/){ die "Quitting...\n"; }
   elsif($resp =~ m/^y/){ system("mv '$file.temp' '$file'");}
   else{ system("rm '$file.temp'");}# NOTE: if you are on Windows, change 'rm' to 'del' ! 
}

}
