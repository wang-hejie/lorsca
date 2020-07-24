#!/usr/bin/perl -w
use strict;
use warnings;
use POSIX ":sys_wait_h";
 
# Input
# ARGV[0]: t.log的存储路径
# ARGV[1]: 纠错命令

# Output
# ARGV[0]/t.log: 存储运行时间和运行内存峰值的日志

# pipe(CHILD_RDR, PARENT_WTR);

my $folder=$ARGV[0];  # 第一个参数是存储路径
if (-e $folder) {print "$folder folder exist\n";}
		else {`mkdir $ARGV[0]`;}

defined(my $pid=fork()) or die "failed\n";
if($pid != 0){  # Parent
	print "parent:$pid++++++++++++++++\n";
	sleep(5); 
	my $max = 0;
	# close CHILD_RDR;
	my $maxcommand="";
	
	while ((my $pst = waitpid(-1, WNOHANG)) ==0){  # 当Child还没执行完
		sleep(5);
		print "-----$pst-----\n";

		my @array =split(" ", `ps ux --sort=rss | grep -v perl|grep -v bash|grep -v ps|grep -v top|grep -v ?|grep -v awk|tail -n 1 | awk '{print \$6,\$11}'`);  # $6: rss; $11: command
		my $memory=$array[0];
		my $command=$array[1];
		print "$memory,$command\n";
                if($max < $memory) {$max = $memory;$maxcommand = $command;}
	}
	$max=$max/1024/1024;
	print "memory $max finished\n";

	# 向t.log中写入运行内存峰值
	open (FH,">>$ARGV[0]/t.log") or die "$ARGV[0]/t.log can't open in Parent, $!";
	print FH "memory: $max\n$maxcommand\n";
	close(FH);
}
else{  # Child
	print "child:$pid--------------------\n";
	# close PARENT_WTR;
	my $start_time=time();
	`$ARGV[1]`;  # 第二个参数是纠错命令

	my $end_time = time();
	my $elapsed_time =$end_time - $start_time;
	my $minute= $elapsed_time/60;

	# 向t.log中写入运行时间
	open(FH, ">$ARGV[0]/t.log") or die "$ARGV[0]/t.log can't open in Child, $!";
	print FH "time: $minute m \n";
	close(FH);
	print "time: $minute finished!\n";
	exit(0);
}
