#!/usr/bin/env perl
use strict;
use Sys::Hostname;
use Log::Log4perl;
use FindBin;
my $host = hostname();
my $user = $ENV{ USER };
# script that monitors the cpu utilization
my ($logFile)=@ARGV;
my $logdir;;
if(!defined($logdir)){$logdir =$FindBin::RealBin;}
if(!defined($logFile)){$logFile="$logdir/monitorCPU.log";}
my $logConf=qq{
	log4perl.rootLogger          = INFO, Logfile, Screen
    log4perl.appender.Logfile          = Log::Log4perl::Appender::File
    log4perl.appender.Logfile.filename = $logFile
    log4perl.appender.Logfile.layout   = Log::Log4perl::Layout::PatternLayout
    log4perl.appender.Logfile.layout.ConversionPattern = [%p : %c - %d] - %m{chomp}%n
    log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
    log4perl.appender.Screen.stderr  = 0
    log4perl.appender.Screen.layout = Log::Log4perl::Layout::PatternLayout
    log4perl.appender.Screen.layout.ConversionPattern = [%p : %c - %d] - %m{chomp}%n
};


Log::Log4perl->init(\$logConf);
my $logger=Log::Log4perl->get_logger("monitorCPU");
$logger->info("Host: $host. Starting for user '$user'!");
for(;;){
	my $r=undef;
	# poll the utilization for a few seconds
	for(my$i=0;$i< 15;$i++) {
		$r=pollUtil();
		if( $r ){ 
#			print "We have activity\n";
			last ;
		}  # we have activity
		sleep 2;
	}
	if(! defined($r) ){ 
		my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
		my @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
		my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
		my $year = 1900 + $yearOffset;
		my $theTime = "$hour:$minute:$second, $weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year";
		$logger->info("Host: $host. Nothing is using the CPU. Exiting!");
		exit(0); 
	}
	sleep 300; # wait for 5 mins before we repeat
}




sub pollUtil{
	my $user = $ENV{ USER };
	my $returnValue=0;
	my $cmd="top -b -n 1 | grep $user | awk '{print \$9}'";
#	print "Running $cmd\n";
	open(my $reader, "$cmd |");
	while(my $u=<$reader>){

		$u=~/(\d+)/;$u=$1;
#		print "The utilization is $u\n";
		# if we have a utilization > 50% we are still running something
		if ($u > 50  and $u > $returnValue){
			$returnValue=$u;	
		}
	}
	close($reader);
	if($returnValue==0){ return undef;}
	return $returnValue;
}