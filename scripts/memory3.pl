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

my $former_mem = `free -m | grep Mem | awk '{printf \$3}'`;  # 单位: M
print "former_mem = $former_mem\n";

defined(my $pid=fork()) or die "failed\n";
if($pid != 0){  # Parent
	print "parent:$pid++++++++++++++++\n";
	sleep(5); 
	my $max_free = 0;  # free得到的最大内存，输出
	my $max_ps = 0;    # ps得到的最大内存，不输出
	# close CHILD_RDR;
	my $maxCommand="";
	
	while ((my $pst = waitpid(-1, WNOHANG)) ==0){  # 当Child还没执行完
		sleep(5);
		print "-----$pst-----\n";

		# 用free抓内存使用峰值
		my $memory_free = `free -m | grep Mem | awk '{printf \$3}'`;  # 单位: M
		print "memory_free = $memory_free\n";
		if($memory_free>$max_free) {$max_free = $memory_free;}

		# 只用ps抓内存使用最大的命令，不用它抓内存使用峰值
		my @array =split(" ", `ps ux --sort=rss | grep -v perl|grep -v bash|grep -v ps|grep -v top|grep -v ?|grep -v awk|tail -n 1 | awk '{print \$6,\$11}'`);  # $6: rss; $11: command
		my $memory_ps=$array[0];
		my $command=$array[1];
		print "$memory_ps,$command\n";
                if($max_ps < $memory_ps) {$max_ps = $memory_ps;$maxCommand = $command;}
	}

	# 计算自纠错软件实际使用内存峰值
	my $maxMem = ($max_free - $former_mem) / 1024;  # 单位: G

	# 向t.log中写入运行内存峰值
	open (FH,">>$ARGV[0]/t.log") or die "$ARGV[0]/t.log can't open in Parent, $!";
	print FH "maxMem: $maxMem\n";
	print FH "maxCommand: $maxCommand\n";
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
