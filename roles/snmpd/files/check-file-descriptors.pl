#!/usr/bin/perl -w
# nagios: -epn

# Counts the number of open file descriptors. A value of 0 indicates an error.

use strict;
use warnings;
my $fd_count= `find /proc/*/fd/* 2>> /dev/null | wc -l`;
print "$ARGV[1]\n";
print "integer\n";
print "$fd_count";
exit;
