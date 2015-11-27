#!/usr/bin/perl -w
#
# Auteur mca
#

use strict;
use warnings;

my ($cpu,$user,$nice,$system,$idle,$iowait,$irq,$sftirq,$steal);

my $pourcIdle;
my $pourcUser;
my $pourcNice;
my $pourcSystem;
my $pourcWait;
my $pourcHI;
my $pourcSI;
my $pourcST;
#definition du nom du fichier temporaire
my $file;
my @Array_last;
my @Array;
$file = "/tmp/check-snmp-cpu.tmp";
my $i=0;
my $j=0;
my @last_values;

#On récupére le dernier champ du deuxiéme argument pour connaitre le cpu int�rog�
my @tab_test = split ('\\.',$ARGV[1]);
my $val=@tab_test;
my $val_cpu=$tab_test[$val-1];

$file = "/tmp/check-snmp-cpu-$val_cpu.tmp";

#on test si le fichier est initialisé
if (-f $file)
{
        #On recupére les anciennes valeurs pour pouvoir calculer la charge CPU
        open(FILE,"<".$file);
        while (my $row = <FILE>)
        {
                @last_values = split(":",$row);
                $Array_last[0] = $last_values[0];
                $Array_last[1] = $last_values[1];
                $Array_last[2] = $last_values[2];
                $Array_last[3] = $last_values[3];
                $Array_last[4] = $last_values[4];
                $Array_last[5] = $last_values[5];
                $Array_last[6] = $last_values[6];
                $Array_last[7] = $last_values[7];
                $Array_last[8] = $last_values[8];
        }
        close(FILE);
        #On stocke les nouvelles valeurs dans un tableau
        open (FICHIER,"< /proc/stat");
        while (my $ligne = <FICHIER>)
        {
                if ($ligne=~ /^cpu$val_cpu\s/)
                {
                     ($cpu,$user,$nice,$system,$idle,$iowait,$irq,$sftirq,$steal) = split / /,$ligne;
                     $Array[0] = $cpu;
                     $Array[1] = $user;
                     $Array[2] = $nice;
                     $Array[3] = $system;
                     $Array[4] = $idle;
                     $Array[5] = $iowait;
                     $Array[6] = $irq;
                     $Array[7] = $sftirq;
                     $Array[8] = $steal;
                }
        }
        close(FICHIER);
}
else
{
       open (FICHIER,"< /proc/stat");
       open (FILE,">".$file);

       while (my $ligne = <FICHIER>)
       {
              if ($ligne=~ /^cpu$val_cpu\s/)
              {
                     ($cpu,$user,$nice,$system,$idle,$iowait,$irq,$sftirq,$steal) = split / /,$ligne;
                     print FILE $cpu.":".$user.":".$nice.":".$system.":".$idle.":".$iowait.":".$irq.":".$sftirq.":".$steal."\n";
              }
       }

       close (FILE);
       close (FICHIER);
       print "$ARGV[1]\n";
       print "string\n";
       print "OK - Donnes en cours d'initialisation\n";
       exit;
}

#Ecriture dans le fichier tmp des nouvelles valeurs cpu
open (FICHIER,"< /proc/stat");
open (FID, ">".$file);
while (my $ligne = <FICHIER>)
{
       if ($ligne=~ /^cpu$val_cpu\s/)
       {
        ($cpu,$user,$nice,$system,$idle,$iowait,$irq,$sftirq,$steal) = split / /,$ligne;
        print FID $cpu.":".$user.":".$nice.":".$system.":".$idle.":".$iowait.":".$irq.":".$sftirq.":".$steal."\n";
       }
}
close FID;
close FICHIER;

my $nb_elem = @Array;
my $pourcTotalUse;

$i=$val_cpu;

if ($Array[0] eq $Array_last[0])
{
       my $cpuUser = $Array[1];
       my $cpuNice = $Array[2];
       my $cpuSystem = $Array[3];
       my $cpuIdle = $Array[4];
       my $cpuWait = $Array[5];
       my $cpuHI = $Array[6];
       my $cpuSI = $Array[7];
       my $cpuST = $Array[8];

       my $last_cpuUser = $Array_last[1];
       my $last_cpuNice = $Array_last[2];
       my $last_cpuSystem = $Array_last[3];
       my $last_cpuIdle = $Array_last[4];
       my $last_cpuWait = $Array_last[5];
       my $last_cpuHI = $Array_last[6];
       my $last_cpuSI = $Array_last[7];
       my $last_cpuST = $Array_last[8];

$pourcTotalUse = 
sprintf("%.2f",(($cpuIdle+$cpuUser+$cpuNice+$cpuSystem+$cpuWait+$cpuHI+$cpuSI+$cpuST)-($last_cpuIdle+$last_cpuUser+$last_cpuNice+$last_cpuSystem+$last_cpuWait+$last_cpuHI+$last_cpuSI+$last_cpuST)));

       #calcul de la charge CPU
       if ($pourcTotalUse == 0) {
              print "$ARGV[1]\n";
              print "string\n";
              print "KO - Intervalle de check trop court \n";
              exit;
       }

       $pourcIdle = sprintf("%.2f",(($cpuIdle-$last_cpuIdle)/($pourcTotalUse)*100));
       $pourcUser = sprintf("%.2f",(($cpuUser-$last_cpuUser)/($pourcTotalUse)*100));
       $pourcNice = sprintf("%.2f",(($cpuNice-$last_cpuNice)/($pourcTotalUse)*100));
       $pourcWait = sprintf("%.2f",(($cpuWait-$last_cpuWait)/($pourcTotalUse)*100));
       $pourcSystem = sprintf("%.2f",(($cpuSystem-$last_cpuSystem)/($pourcTotalUse)*100));
       $pourcHI = sprintf("%.2f",(($cpuHI-$last_cpuHI)/($pourcTotalUse)*100));
       $pourcSI = sprintf("%.2f",(($cpuSI-$last_cpuSI)/($pourcTotalUse)*100));
       $pourcST = sprintf("%.2f",(($cpuST-$last_cpuST)/($pourcTotalUse)*100));

        print "$ARGV[1]\n";
        print "string\n";
        print "OK | cpu_user=$pourcUser cpu_system=$pourcSystem cpu_nice=$pourcNice cpu_wait=$pourcWait cpu_idle=$pourcIdle cpu_hi=$pourcHI cpu_si=$pourcSI cpu_st=$pourcST\n";
}
else
{
       print "$ARGV[1]\n";
       print "string\n";
       print "KO - Erreur CPU \n";
       exit;
}

