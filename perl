#!/usr/bin/perl

use strict;
use warnings;
use Expect;
use Cwd;
use Cwd 'abs_path';
use File::Copy;

my $retry = 0;
my $Login_Timeout = '100';
my $Expect_Timeout = '100';

# my $Year_Month_Day = `date '+%y%m%d'`+0;
my $Site_Svc_Sys_Name_Grep;
my @Connect_Load_Array;
my $Programable_CWD = "/export/home/perl";
my $Env_Configuration_Dir = "$Programable_CWD/cfg";
my $Env_Memo_Dir = "$Programable_CWD/memo";
my $System_List = "$Env_Configuration_Dir/system_list.cfg";
my $Connect_Log_Dir = "$Programable_CWD/log";
my $Auto_Run_Dir = "$Programable_CWD/run";
#SYSTEM INFO
my @ArgvSite =ment(13-07-05) : #$lexp=shift 보다 먼저 선언 되어야함.
my $Option_ARGV_Num = $#ARGV;

# print "\n<	argv test 0 = $Option_ARGV[0]	>\n";
# print "\n<	argv test 1 = $Option_ARGV[1]	>\n";
# print "\n<	argv test 2 = $Option_ARGV[-1]	>\n";

my $yday = `date '+%Y%m%d'`+0; my $Year_Month_Day = `date '+%y%m%d'`+0; my $day = `date '+%m%d'`+0;
my $User_Session = `who -am |grep "+" |awk '{print \$1 \$8}'`; #By.Beyond_Comment(13-07-04) : User + session - root23536
my $Length_of_User_Session = length($User_Session); #By.Beyond_Comment(13-07-04) : 마지막 개행 문자 제거 하기 위한 Langth 구함.- 130704.hk.tel.ssh.root23536?
my $ConnectUser_Terminal = substr( $User_Session,0,$Length_of_User_Session-1); #By.Beyond_Comment(13-07-04) : 마지막 개행 문자 제거
my $Get_User_ID = `who -am |grep "+" |awk '{print \$1}'`;
my $Length_of_User = length($Get_User_ID);
my $User_ID = substr( $Get_User_ID,0,$Length_of_User-1);

my $lexp = shift;		#By.Beyond_Comment(13-07-05) : @ARGV 가 아래 정의 되면 첫번째 인자가 사라짐.
my $exp = new Expect;

my $Log_Write_Dir = "$Connect_Log_Dir/$CustomerName";
my $Last_Log_File_Name ="$Log_Write_Dir/$Year_Month_Day.$ScriptName.$ConnectUser_Terminal";

my @Folder_List = ("$Env_Configuration_Dir", "$Connect_Log_Dir", "$Env_Memo_Dir", "$Auto_Run_Dir","$Log_Write_Dir"); #By.Beyond_Comment(13-07-12) : 배열내 변수 넣는 방법

#By.Beyond_Comment(13-07-16) : @Folder_List 내 폴더를 생성 하고 생성된 폴더들의 권한을 777로 변경
foreach(@Folder_List) {
	&Make_Directory($_);
	&Change_Owner_Group($_);
}

#By.Beyond_Comment(13-07-16) : 해당 폴더의 권한을 777로 변경
sub Change_Owner_Group {
	foreach(@Folder_List) {
		# chown -R "$uid:$gid" "$_";
		chmod (0777, $_);
	}
}
#By.Beyond_Comment(13-07-04) : Expect 전 접근 사용자 기록
$exp->slave->clone_winsize_from(\*STDIN);
open(FHANDLE, ">>$Last_Log_File_Name") || die "Can't open test.txt!";
print FHANDLE "################### NOSTECH ################# \n";
print FHANDLE `date`;
print FHANDLE `who -am`;
print FHANDLE "################### NOSTECH ################# \n";
close(FHANDLE);

#By.Beyond_Comment(13-07-04) : Expect 실행 로그 기록
$exp->log_file("$Log_Write_Dir/$Year_Month_Day.$ScriptName.$ConnectUser_Terminal");

#Main 스크립트 시작
if ($Option_ARGV_Num == 1){	#By.Beyond_Comment(13-07-05) : 옵션이 두개일 경우
	# print "\n<	두개일 경우 실	>\n";
	if($Option_ARGV[0] eq "-run"){
		# print "\n<	argv1==== $Option_ARGV[1]	>\n";
		&Option_Run();
	}else{
		&Run_Script();
	};
}elsif($Option_ARGV_Num == 0){	#By.Beyond_Comment(13-07-05) : 옵션이 하나일 경우 옵션 case 별 확인
	if($Option_ARGV[0] eq "-memo") {
		&Write_Memo();
		&Run_Script();
	}elsif($Option_ARGV[0] eq "-run"){
		&Option_Run();
	}elsif ($Option_ARGV[0] eq "-help"){
		&Help_Usage_Print($ScriptName);
		exit 0
	}
}elsif($Option_ARGV_Num == -1){
	&Run_Script();
}else{  &Help_Usage_Print($ScriptName); }
# }else{  die "Try `$ScriptName -help' for more information..\n"; }

#By.Beyond_Comment(13-07-16) : Main Script Start
sub Run_Script {
	# &Current_Folder_Check();
	&Make_File($System_List);
	&Connect_To_System();
}

#By.Beyond_Comment(13-07-16) : -run 옵션이 있을 경우 해당 파일을 찾아서 expect를 통해 해당 서버에 한줄씩 입력.
sub Option_Run {
	if ($Option_ARGV_Num == 1){	#By.Beyond_Comment(13-07-05) : 옵션이 두개일 경우
		my $Second_Option = "$Option_ARGV[1]";
		print "\n<	argv1 = $Second_Option	>\n";
		my $Option_Run_File = "$Programable_CWD/run/$Second_Option";
		if (-f "$Option_Run_File") {
			&Run_Script();
			# my $Get_Cat_Run_File = &Delete_Comment($Option_Run_File);
			# my @Cat_Run_File = `cat $Get_Cat_Run_File`;
			# my @Cat_Run_File = &Delete_Comment(`sed -e '/^#/d' -e '/^\$/d' $Option_Run_File`);
			my @Cat_Run_File = &Delete_Comment(`cat $Option_Run_File`);
			# print "\n<	------------- @Cat_Run_File 	>\n";
			&Put_Command_Expect(@Cat_Run_File);
		}else{
			my @Cat_Run_File = `cat $Option_Run_File`;
			&Make_File($Option_Run_File);
			print "\n<	$Option_Run_File 파일에 실행될 명령어를 넣어 주세요.	>\n";
			&Run_Script();
		}

	}else{
		my $Option_Run_Dir = "$Programable_CWD/run";
		&Make_Directory($Option_Run_Dir);
		my $List_Option_Run_Dir = `ls $Option_Run_Dir`;
		print "<\n ####################################################################	$List_Option_Run_Dir ####################################################################	>\n";
		print STDOUT ">>> 자동으로 실행할 파일의 이름은 무었입니까? ??? \t";
		chomp(my $Run_File_Input = <STDIN>);
		my $Option_Run_File = "$Programable_CWD/run/$Run_File_Input";

		print "\n<	optime run file = $Option_Run_File	>\n";

		if (-f "$Option_Run_File") {
			&Run_Script();
			my @Cat_Run_File = `cat $Option_Run_File`;
			&Put_Command_Expect(@Cat_Run_File);
		}else{
			my @Cat_Run_File = `cat $Option_Run_File`;
			&Make_File($Option_Run_File);
			print "\n<	$Option_Run_File 파일에 실행될 명령어를 넣어 주세요.	>\n";
			&Run_Script();
		}
	}
}


#By.Beyond_Comment(13-07-16) : ARGV에 -memo 옵션이 있을 경우 파일 확인 후 메모를 작성 한다.
sub Write_Memo {
	my $Get_Dir_Name = "$Programable_CWD/memo";
	my $Chk_CustomerName_memo = "$Get_Dir_Name/$CustomerName.memo";
	if (-f "$Chk_CustomerName_memo") {		#By.Beyond_Comment(13-07-05) : ~/home/memo 내의 customer.memo 확인 하고 없으면 파일 만듬.
	}else{
		&Make_File($Chk_CustomerName_memo);
	}

	my $Service_Memo_Filename ="$CustomerName.$ServiceName.service ";
	my $Forloop_Num = 1;

	LINE:	#By.Beyond_Comment(13-07-10) : loof Control goto/last/next 를 통해 루프를 빠져 나
	for($Forloop_Num = 1; ;$Forloop_Num++) {

	    print STDOUT "########################################################\n";
	    print STDOUT ">>> $ServiceName 에 대한 메모는 s $ScriptName 에 대한 메모는 m 를 입력해 주세요. (exit:x) ??? \t";
	    my $In_Character = <STDIN>;
	    chomp (my $X_Check = $In_Character);	#By.Beyond_Comment(13-07-10) : 아래 x 를 구별 하기 위해 개행문자를 잘라줌.
	    last LINE if($X_Check eq "x");
	    	# $In_Character = uc($In_Character);		#대문자로 변경

        print STDOUT ">>> 메모의 내용을 적어 주세요. ??? \t";
        chomp(my $Memo_Input = <STDIN>);

        if($In_Character eq "m\n") {	#By.Beyond_Comment(13-07-10) : 내용 프린트를 위해 문자 구별
			print "\n<<<  $ScriptName #$Year_Month_Day #$Memo_Input  >>>\n\n";
		}elsif($In_Character eq "s\n"){
			print "\n<<<  $Service_Memo_Filename #$Year_Month_Day #$Memo_Input  >>>\n\n";
		}else{
			print "\n<	옵션이 맞지 않습니다. 	>\n";	#By.Beyond_Comment(13-07-10) : s 나 m 이 아닌 문자시 처음 부터 다시 입력
			goto LINE;
		}

        print STDOUT ">>>> 메모의 내용이 맞습니까 (y/n):\t";
        goto LINE if(<STDIN> eq "n\n");

        #By.Beyond_Comment(13-07-10) : 아래 내용을 memo 내용에 추가함.
		if($In_Character eq "m\n") {
			open(FH, ">>$Chk_CustomerName_memo");
	        print FH
	        "$ScriptName #$Year_Month_Day #$Memo_Input\n";
	        close (FH);
		}elsif ($In_Character eq "s\n") {
			open(FH, ">>$Chk_CustomerName_memo");
	        print FH
	        "$Service_Memo_Filename #$Year_Month_Day #$Memo_Input\n";
	        close (FH);
	    }
	}
}

sub Memo_System_Auth {
	my @Ary = @_;
	my $Result_Allow = `sed -e '/^#/d' -e '/^\$/d' $Env_Configuration_Dir/hosts.allow |grep $Ary[0] |wc -l`;
	my $Result_Deny = `sed -e '/^#/d' -e '/^\$/d' $Env_Configuration_Dir/hosts.deny|grep $Ary[0] |wc -l`;
	if ($Result_Allow >= 1) { 		#By.Beyond_Comment(13-07-04) : cfg/hosts.allow 파일내 사용자 존재 여부 확인
		if ($Result_Deny >= 1){ print "\n<	메모 읽기 없음. 	>\n"; } #By.Beyond_Comment(13-07-04) : hosts.deny에 등록된 사용자는 메모를 읽지 않음.
		else{
			&Read_Memo();
		}

	}
}

sub Read_Memo {
	my $Get_Dir_Name = "$Programable_CWD/memo";
	if (-d "$Get_Dir_Name") { 	#By.Beyond_Comment(13-07-05) : ~/home/memo 디렉토리 생성
	}else{
		# print "<	$Get_Dir_Name 디렉토리를 만듭니다.					> \n";
		&Make_Directory($Get_Dir_Name);
	}

	my $Chk_CustomerName_memo = "$Get_Dir_Name/$CustomerName.memo";
	if (-f "Get_Dir_Name/$CustomerName.memo") {		#By.Beyond_Comment(13-07-05) : ~/home/memo 내의 customer.memo 확인 하고 없으면 파일 만듬.
	}else{
		&Make_File($Chk_CustomerName_memo);
	}

	my $Read_Customer_Memo = `cat $Programable_CWD/memo/$CustomerName.memo |grep "^$CustomerName.$ServiceName.service" |sed -n 's/$CustomerName.$ServiceName.service//p'`;
	my $Read_Server_Memo = `cat $Programable_CWD/memo/$CustomerName.memo |grep "$ScriptName" |awk 'NR==1'`;

	print "\n********************************* Service HISTORY ********************************\n";
	print "\n 새로운 메모를 저장 하시려면 $ScriptName -memo 옵션을 사용 하여 추가 하세요.\n";
	print "\n$Read_Customer_Memo\n";
	print "********************************* SYSTEM HISTORY *********************************\n";
	print "\n$Read_Server_Memo\n";
	print "**********************************************************************************\n";
}

#By.Beyond_Comment(12-07-12) : 실행파일의 설정을 찾아 접속 한다.
sub Connect_To_System {
#By.Beyond_Comment(12-07-17) :Grep 하여 설정을 찾을수 없으면 만들고 2개 이상 이면 첫번째만 실행
	LINE: my $Grep_Num = `grep $ScriptName $System_List |grep -v "#"|wc -l`;
	if ($Grep_Num == 1){
		$Site_Svc_Sys_Name_Grep = `grep $ScriptName $System_List |grep -v "#"`;
		# $Site_Svc_Sys_Name_Grep = &Delete_Comment($System_List);
		@Connect_Load_Array = split /\,/, $Site_Svc_Sys_Name_Grep ;
	}elsif($Grep_Num == 0){
		print "\n<	$ScriptName 설정이 $System_List에 존재 하지 않습니다.	>\n";
		print STDOUT ">>> $ScriptName 에 대한 설정을 하시겠습니까?(y/n):\t";
		last if(<STDIN> eq "n\n"); 
		&STDIN_Connect_Cfg($System_List);
		goto LINE;
	}else{
		print "$Site_Svc_Sys_Name_Grep\n";
		print "\n<	$ScriptName 이 하나이상 입니다. $System_List 에서 첫번째 검색만 유효 합니다.	>\n";
		$Site_Svc_Sys_Name_Grep = `grep $ScriptName $System_List |grep -v "#"|awk 'NR==1'`;
		@Connect_Load_Array = split /\,/, $Site_Svc_Sys_Name_Grep ;
	}
	#By.Beyond_Comment(12-07-17) :첫번째 접속 protocol이 ssh/telnet에 따라 분리
	shift @Connect_Load_Array;
	shift @Connect_Load_Array;
	my @Ary = @Connect_Load_Array;
	if ($Connect_Load_Array[0] eq "ssh") {
		&Ssh_Connect_to_System_Spawn(@Connect_Load_Array);	#By.Beyond_Comment(12-07-13) :SSH Connect Sub
	}else{
		&Telnet_Connect_to_System_Spawn(@Connect_Load_Array);	#By.Beyond_Comment(12-07-13) :TELNET Connect Sub
	}
}

#By.Beyond_Comment(12-07-16) : 처음이  SSH접속 시
sub Ssh_Connect_to_System_Spawn {
	my @Ary = @_;
	$exp->spawn("ssh $Ary[2]\@$Ary[1] -p $Ary[4] \n");
	$exp->expect($Login_Timeout,
	[qr 'word:' => sub {$exp->send("$Ary[3]\n")},[Login_Timeout => \&Call_Interact]],
	[qr '(yes/no) ?'   => \&InputYes],[Login_Timeout => \&Call_Interact],);

	#$exp->expect($Login_Timeout,
	#[qr '[assword: # > \$] $' => sub {$exp->send("$Ary[3]\n")},[Login_Timeout => \&Call_Interact]],);

	for(my $i=0;$i<5;$i++){shift @Ary;}
	#	$exp->expect($Login_Timeout,[qr '[: \] # > \$ \%] $' => sub {$exp->send("who -am\n")}],[Login_Timeout => \&Call_Interact],); #By.Beyond_Comment(13-07-03) : session에 접속한 정보자 정(who -am)
		my $Connect_Load_Array_Num = @Ary;
		my $Forloop_Num = ($Connect_Load_Array_Num)/5;
#2016
    $exp->expect($Login_Timeout,
        [qr '#' => sub {$exp->send("who -am","\n")}],
        [qr '%' => sub {$exp->send("who -am","\n")}],
        [qr '[: \] # > \$ \%] $' => sub {$exp->send("who -am","\n")}],
    [Login_Timeout => \&Call_Interact],);

	for (my $i=0;$i<$Forloop_Num;$i++) {
		if ($Ary[0] eq "ssh") {
			my @Ary = @Ary ;
			&ExpectSSH(@Ary);
		}elsif($Ary[0] eq "telnet") {
			sleep 1;
			my @Ary = @Ary ;
			&ExpectTelnet(@Ary);
		}else{
			&Put_Command_Expect(@Ary);
		}
	for(my $i=0;$i<5;$i++){shift @Ary;}
	}
}

#By.Beyond_Comment(12-07-16) :처음이 telnet 접속 시
sub Telnet_Connect_to_System_Spawn {
	my @Ary = @_;
	$exp->spawn("telnet $Ary[1] $Ary[4] \n");
	$exp->expect($Login_Timeout,[qr 'gin:' => sub {$exp->send("$Ary[2]\n")}],[Login_Timeout => \&Call_Interact],);
	$exp->expect($Login_Timeout,[qr 'word:' => sub {$exp->send("$Ary[3]\n")}],[Login_Timeout => \&Call_Interact],);
	$exp->expect($Login_Timeout,[qr '[: \] # > \$ \%] $' => sub {$exp->send("\n")}],[Login_Timeout => \&Call_Interact],);
	#$exp->expect($Login_Timeout,[qr '[: \] # > \$ \%] $' => sub {$exp->send("who -am\n")}],[Login_Timeout => \&Call_Interact],);

	for(my $i=0;$i<5;$i++){shift @Ary;}
	my $Connect_Load_Array_Num = @Ary;
	my $Forloop_Num = ($Connect_Load_Array_Num)/5;

	for (my $i=0;$i<$Forloop_Num;$i++) {
		if ("$Ary[0]" eq "ssh") {
			my @Ary = @Ary ;
			&ExpectSSH(@Ary);
		}elsif($Ary[0] eq "telnet") {
			my @Ary = @Ary ;
			&ExpectTelnet(@Ary);
		}else{
			&Put_Command_Expect(@Ary);
		}
		for(my $i=0;$i<5;$i++){shift @Ary;}
	}
}

#By.Beyond_Comment(13-07-04) : 두번째 연결에서 TELNET 일경
sub ExpectTelnet {
	my @Ary = @_;
	$exp->expect($Login_Timeout,
		[qr '#' => sub {$exp->send("telnet $Ary[1]  $Ary[4]","\n")}],
		[qr '%' => sub {$exp->send("telnet $Ary[1]  $Ary[4]","\n")}],
		[qr '\$' => sub {$exp->send("telnet $Ary[1]  $Ary[4]","\n")}],
		[qr '[: \] # > \$ \%] $' => sub {$exp->send("telnet $Ary[1]  $Ary[4]","\n")}],
	[Login_Timeout => \&Call_Interact],);
	$exp->expect($Login_Timeout,
		#By.Beyond_Comment(13-07-03) : login 시 "Ary[2]\n"으로 넣으면 passwd 가 잘못 들어감. "$Ary[2]","\n" 식으로 넣어야함.
		[qr 'ogin:' => sub {$exp->send("$Ary[2]","\n")}],[Login_Timeout => \&Call_Interact],);
		$exp->expect($Login_Timeout,
		[qr 'word:' => sub {$exp->send("$Ary[3]","\n")}],[Login_Timeout => \&Call_Interact],);
#2016
		$exp->expect($Login_Timeout,
		[qr '#' => sub {$exp->send("who -am","\n")}],
		[qr '%' => sub {$exp->send("who -am","\n")}],
		[qr '[: \] # > \$ \%] $' => sub {$exp->send("who -am","\n")}],
		[Login_Timeout => \&Call_Interact],);

}

#By.Beyond_Comment(13-07-04) : 두번째 연결에서 SSH 일경우
sub ExpectSSH {
	my @Ary = @_;
	$exp->expect($Login_Timeout,
		[qr '#' => sub {$exp->send("ssh $Ary[2]\@$Ary[1] -p $Ary[4]","\n")}],
		[qr '%' => sub {$exp->send("ssh $Ary[2]\@$Ary[1] -p $Ary[4]","\n")}],
		[qr '\$' => sub {$exp->send("ssh $Ary[2]\@$Ary[1] -p $Ary[4]","\n")}],
		[qr '[: \] # > \$ \%] $' => sub {$exp->send("ssh $Ary[2]\@$Ary[1] -p $Ary[4]","\n")}],
	[Login_Timeout => \&Call_Interact],);
	$exp->expect($Login_Timeout,
	[qr 'word:' => sub {$exp->send("$Ary[3]","\n")}],
	[qr '(yes/no) ?'   => \&InputYes],[Login_Timeout => \&Call_Interact],);

#2016
#	$exp->expect($Login_Timeout,
#	[qr 'assword:' => sub {$exp->send("$Ary[3]\n")},[Login_Timeout => \&Call_Interact]],);

	$exp->expect($Login_Timeout,
		[qr '#' => sub {$exp->send("who -am","\n")}],
		[qr '%' => sub {$exp->send("who -am","\n")}],
		[qr '[: \] # > \$ \%] $' => sub {$exp->send("who -am","\n")}],
	[Login_Timeout => \&Call_Interact],);
}

#By.Beyond_Comment(13-07-04) : 연결 후 남아 있는 명령행을 실행 한다.
sub Put_Command_Expect {
	my @Ary = @_;
	#$exp->expect($Login_Timeout,
	#[qr 'assword:' => sub {$exp->send("$Ary[0]\n")},[Login_Timeout => \&Call_Interact]],);
	my $Ary = @Ary;
	for(my $i=0;$i<$Ary;$i++){
	$exp->expect($Expect_Timeout,
	[qr '#' => sub {$exp->send("$Ary[$i]","\n")}],
	[qr '%' => sub {$exp->send("$Ary[$i]","\n")}],
	[qr '\$' => sub {$exp->send("$Ary[$i]","\n")}],
	[qr 'word:' => sub {$exp->send("$Ary[$i]","\n")}],
	[qr '[ \] # > \$ \%] $' => sub {$exp->send("$Ary[$i]","\n")}],[Login_Timeout => \&Call_Interact],);
	}
	exp_continue;
}

#By.Beyond_Comment(12-07-16) :설정파일에 실행 설정이 없으면 묻고 생성한다.
sub STDIN_Connect_Cfg {
	my $System_List = $_[0];
	my @Put_Con_Cfg = ("$0", "=");

	for(my $i=1;;$i++){
	print STDOUT ">>> 설정을 원하는 파일명은 [$0]입니다.(exit:x)\n";
	print STDOUT ">>> [$0]의 [$i]번째 접속 Protocol(EX:ssh,telnet)는 (경유접속 서버)?\t";
	chomp(my $Input_Protocol = <STDIN>);
	last LINE if($Input_Protocol eq "x");
	print STDOUT ">>> [$0]의 [$i]번째 접속 IP는(경유접속지가 없을 경우 해당 장비 IP입력)?\t";
	chomp(my $Input_Ip_Address = <STDIN>);
	print STDOUT ">>> [$0]의 [$i]번째 접속 계정은?(exit:x)\t";
	chomp(my $Input_User = <STDIN>);
	last LINE if($Input_User eq "x");
	print STDOUT ">>> [$0]의 [$i]번째 접속 패스워드는?\t";
	chomp(my $Input_Passwd = <STDIN>);
	print STDOUT ">>> [$0]의 [$i]번째 접속 포트는?\t";
	chomp(my $Input_Port = <STDIN>);
	push (@Put_Con_Cfg,$Input_Protocol,$Input_Ip_Address,$Input_User,$Input_Passwd,$Input_Port);
	print "\n>>> @Put_Con_Cfg <<<\n";
	print STDOUT ">>>> Configure? (y/n):\t";
	goto LINE if(<STDIN> eq "n\n");
	}

	LINE: open(FH, ">>$System_List") || die " Can\'t open $System_List";
	my $string = join(',', @Put_Con_Cfg);
	print FH $string;
	close (FH);
}

#By.Beyond_Comment(12-07-16) :File 존재를 확인 하여 파일을 생성 합니다.
sub Make_File {
	my $Get_File_Name = $_[0];
	if (-f "$Get_File_Name") {
	}else{
	print "\n<	$Get_File_Name 파일을 생성 합니다.	>\n";
	open (FH, "> $Get_File_Name"); close (FH);
	}
}


sub InputPword {
	if ($retry > 0) { die "Input Passwd Login Error\n"; }
	$lexp->send("$_[0] \n");
	$retry++;
	exp_continue;
}

#By.Beyond_Comment(12-07-14) :SSH Key값 저장
sub InputYes {
	my $lexp = shift;
	$lexp->send("yes", "\n");
	exp_continue;
}

#By.Beyond_Comment(12-07-14) :Expect 를 반환
sub Call_Interact { $exp->interact(); }

sub Make_Directory {
	my $Get_Dir_Name = $_[0];
	# if (-d "$Get_Dir_Name") {
	# }else{
		# mkdir $Get_Dir_Name;
		# print "<	$Get_Dir_Name 디렉토리를 생성 합니다.						> \n";
	# }
		unless(-e $Get_Dir_Name or mkdir $Get_Dir_Name) {
		die "Unable to create : $Get_Dir_Name\n";
	}
}

#By.Beyond_Comment(12-07-12) : 실행 파일의 폴더를 체크 한다.
# sub Current_Folder_Check {
# 	my $Current_CWD = getcwd;

# 	if ($Current_CWD eq $Programable_CWD) {
# 	} else {
# 		&Connect_Log_Dir($Programable_CWD);
# 		print "<	$0 실행 파일을 $Programable_CWD 로 이동 합니다.					> \n";
# 		move("./$0","$Programable_CWD");
# 	}
# }

#By.Beyond_Comment(12-07-12) : 사용방법을 출력 하여 옵션을 출력 합니다.
sub Help_Usage_Print {
	my $Ary = $_[0];
	print "usages: \n";
	print "    $Ary -memo : <customer나 서비스에 대한 메모 기능디> \n";
	print "    $Ary -run : <리모트 호스트에서 filename을 확인후 명령어를 순차적으로 실행> \n";
	print "    $Ary -run filename : <리모트 호스트에서 filename의 명령어를 순차적으로 실행> \n";
}

sub Delete_Comment {
        my @result =@_;
        # print "\n<	처음 받은 파일내 변수 = @result	>\n";
        foreach (@result) {
        # s/^#.*$//gm;          # 샵으로 시작하는 라인 제거
        #By.Beyond_Comment(13-07-16) : #라인제거 tab 제거 / 문장뒤 #제
        s/(?:\r?\n|\r)?[ \t]*(#.*?)?(?=\r?\n|\r)//g;
        chomp;
        }
        # print "\n<	리턴전 값 = @result	>\n";
        return @result;
}

$exp->interact();

