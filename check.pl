#!/usr/bin/perl -w
# Copyright (c) BMK 2012/8/14
# Writer:         Luosz <luosz@biobreeding.com.cn>
# Program Date:   2012/8/30.


use strict;
use Cwd;
use Getopt::Long;
use Data::Dumper;
use File::Basename qw(basename dirname);
use FindBin qw($Bin $Script);

my $programe_dir=basename($0);
my $path=dirname($0);

my $ver    = "1.0";
my $Writer = "Luosz <luosz\@biobredding.com.cn>";
my $Data   = "2015/1/13";
my $BEGIN=time();
#######################################################################################

# ------------------------------------------------------------------
# GetOptions
# ------------------------------------------------------------------
my ($id,$out,$run,$dis,$user);
GetOptions(
			"h|?" =>\&help,
			"o:s"=>\$out,
			"id:s"=>\$id,
			"run"=>\$run,
				"dis"=>\$dis,
				"user:s"=>\$user,
			) || &help;

&help if (! $id && !$run);
&help if ( $dis && !$run);
&help if ($user && !$run);

sub help
{
	print <<"	Usage End.";
    Description:
        Writer  : $Writer
        Data    : $Data
        Version : $ver
        function: check the Check_file and qstat running
        $0

    Usage:

        -id          indir1,indir2,indir3      input more than one dir

        -run         check the running qstat and display the same jobs >= 2
          -dis       display all running qstat jobs dir
          -user      default yourself

                      -id or/and -run 

        -o           outfile

        -h          Help document

	Usage End.
	exit;
}
# ------------------------------------------------------------------
# GetOptions
# ------------------------------------------------------------------

###############Time
my $Time_Start;
$Time_Start = sub_format_datetime(localtime(time()));
################
open (OUT,">$out") || die $! if defined $out;
my %runsh;my $qstat=undef;
my %runsh_count;
(defined $user)?($user="-u $user"):($user=" ");
if (defined  $run) {
	chomp($qstat = `qstat $user `);
	my @line = split /\n/, $qstat;
	for (my $i=0; $i<@line; $i++) {
		$line[$i]=~s/^\s*//;
		next unless ($line[$i] =~/^\d/);
		my ($id)=split /\s+/, $line[$i];
		chomp(my $qstat_job=`qstat -j $id `);
		my @job_detail=split/\n/,$qstat_job;
		my $cwd;my $job_name;
		for (my $i=0;$i<@job_detail ;$i++) {
			if ($job_detail[$i]=~/cwd:/) {
				$cwd=(split/\s+/,$job_detail[$i])[1];
			}
			if ($job_detail[$i]=~/job_name:/) {
				$job_name=(split/\s+/,$job_detail[$i])[1];
			}
		}
		(exists $runsh{"$cwd/$job_name"}) ? ($runsh{"$cwd/$job_name"} .="\t$id") : ($runsh{"$cwd/$job_name"}=$id);
		$runsh_count{"$cwd/$job_name"} ++;
	}
}
if (defined $dis) {
	print "display the running qstat jobs dir:\n";
	foreach (sort keys %runsh){
		print "$runsh{$_}\t$_\n" ;
	}
	print "\n\n";;
}

foreach my $runjob (sort keys %runsh_count){
	if ($runsh_count{$runjob}>=2){
		print "$runjob has more runing:\n$runsh{$runjob}\n\n";
		print OUT "$runjob has more runing:\n$runsh{$runjob}\n\n" if defined $out;
	}
}


my @all_nocheck;
my @all_erro;
my @Running;
if (defined $id) {
	$id=~s/\s+//g;
	my @ids=split/,/,$id;
	foreach my $indir(@ids){
		my %qsubdir;
		my $id_basename=(split/\//,$indir)[-1];
		$indir = &ABSOLUTE_DIR($indir);
		my $qsub=undef;
		($id_basename=~/.*\.sh\.\d+\.qsub/) ? ($qsub=$indir):($qsub=`find $indir -name "*sh*qsub"`);
		my @qsub=split/\n/,$qsub;
		@qsubdir{@qsub}=undef;
		foreach my $qsub_sh(sort keys  %qsubdir){
			if (!-d $qsub_sh){
				delete $qsubdir{$qsub_sh};
				next;
			}
			my @dir=glob "$qsub_sh/*.sh";
			my @dir_check=glob "$qsub_sh/*.sh.Check";
			my %dir;
			my %dir_check;
			@dir{@dir}=undef;
			@dir_check{@dir_check}=undef;
			my $flag=1;
			my @no_check;
			foreach my $sh_file(sort keys %dir){
				if (exists $dir_check{"$sh_file.Check"}){
					my @erro=glob "$sh_file.e*";
					foreach my $erro(@erro){
						open (ERRO,"$erro") || die $!;
						while (<ERRO>) {
							chomp;
							if ($_=~/\"cluster.local\"/) {
								push @all_erro,$erro;
							}
						}
						close (ERRO);
					}
				}else{
					if (exists $runsh{$sh_file}) {
						push @Running,$sh_file;
						next;
					}
					push @no_check,$sh_file;
					push @all_nocheck,$sh_file;
				}
			}
		}
	}
}


foreach (@Running){
	print "Running:\t$_\n";
	print OUT "Running:\t$_\n" if (defined $out);
}
print "\n";
print OUT "\n" if (defined $out);

foreach (@all_nocheck){
	print "NO check:\t$_\n";
	print OUT "NO check:\t$_\n" if (defined $out);
}
print "\n";
print OUT "\n" if (defined $out);

foreach (@all_erro){
	print "ERRO:\t$_\n";
	print OUT "ERRO:\t$_\n" if (defined $out);
}
print  "\n";
print OUT "\n" if (defined $out);
close (OUT) if defined $out;



###############Time
my $Time_End;
$Time_End = sub_format_datetime(localtime(time()));
&Runtime($BEGIN);


###############Subs
sub sub_format_datetime
#Time calculation subroutine
{
	my($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = @_;
	$wday = $yday = $isdst = 0;
	sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $day, $hour, $min, $sec);
}

sub Runtime 
# &Runtime($BEGIN);
{
	my ($t1)=@_;
	my $t=time()-$t1;
	print "Total $programe_dir elapsed time : [",&sub_time($t),"]\n";
}
sub sub_time
{
	my ($T)=@_;chomp $T;
	my $s=0;my $m=0;my $h=0;
	if ($T>=3600) {
		my $h=int ($T/3600);
		my $a=$T%3600;
		if ($a>=60) {
			my $m=int($a/60);
			$s=$a%60;
			$T=$h."h\-".$m."m\-".$s."s";
		}else{
			$T=$h."h-"."0m\-".$a."s";
		}
	}else{
		if ($T>=60) {
			my $m=int($T/60);
			$s=$T%60;
			$T=$m."m\-".$s."s";
		}else{
			$T=$T."s";
		}
	}
	return ($T);
}

sub ABSOLUTE_DIR
#$pavfile=&ABSOLUTE_DIR($pavfile);
{
	my $cur_dir=`pwd`;chomp($cur_dir);
	my ($in)=@_;
	my $return="";
	if(-f $in){
		my $dir=dirname($in);
		my $file=basename($in);
		chdir $dir;$dir=`pwd`;chomp $dir;
		$return="$dir/$file";
	}elsif(-d $in){
		chdir $in;$return=`pwd`;chomp $return;
	}else{
		warn "Warning just for file and dir\n";
		exit;
	}
	chdir $cur_dir;
	return $return;
}

