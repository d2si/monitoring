#!/usr/bin/perl -w
# nagios: -epn
# Base sur le script e Patrick Proy en GPL
#

use strict;
use warnings;
my @partitions = qw(/var/tmp /dev/shm /eaccelerator);
my @tab_test   = split ('\\.',$ARGV[1]);
my $val        = @tab_test;
my $val_part   = $tab_test[$val-1];
my $partition  = $partitions[$val_part];
if (-d $partition)
{
  my $available = `df $partition | awk '/tmpfs/ {print \$4}'`;
  my $used = `df $partition | awk '/tmpfs/ {print \$3}'`;
  chomp $available;
  chomp $used;
  print "$ARGV[1]\n";
  print "string\n";
  print "OK | available=$available used=$used\n";
}
else
{
  print "$ARGV[1]\n";
  print "string\n";
  print "KO - La partition n'existe pas\n";
}
exit;
