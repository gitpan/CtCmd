##########################################################################
#                                                                        #
# Copyright 2002 Rational Software Corporation.                          #
# All Rights Reserved.                                                   #
# This software is distributed under the Common Public License Version   #
# 0.5 (CPL), and you may use this software if you accept that agreement. #
# You should have received a copy of the CPL with this software          #
# in the file LICENSE.TXT.  If you did not, please visit                 #
# http://www.opensource.org/licenses/cpl.html for a copy of the license. #
#                                                                        #
##########################################################################
use ExtUtils::MakeMaker;
use Config;

# To override ExtUtils::MM_Unix methods:
# require packages SolarisInterposer(for  MY::subdirs ) 
# and Win32C_O (for MY::c_o).  Including these subs inline
# results in their evaluation at compile time and prohibits platform-selective
# overriding of these methods.
# "use" will not work here as it has an implicit "BEGIN".
# XCHEN(9/4/01): add the gcc check
# XCHEN(9/4/01): append the $ATRIA_ROOT runtime seaching path to LIBS
# XCHEN(9/7/01): tested the gcc version2.7 succeed.

my $archlib=$Config{archlib};
my $name=ClearCase::CtCmd;
my $inst_lib=$archlib.'/auto/'.$name;
my $ATRIA_ROOT=$ENV{ATRIA_ROOT}?$ENV{ATRIA_ROOT}:"/usr/atria"; 
my $cleartool = $ATRIA_ROOT.'/bin/cleartool';
my $osver;

$os=$Config{osname};  #why not $^O ?

my %opts = (
	    'NAME'	=> $name,
	    'VERSION_FROM' => 'CtCmd.pm', # finds $VERSION
	    'LIBS' =>' -L. -L'.$ATRIA_ROOT.'/shlib -latriacmdsyn  -latriacmd -latriasumcmd -latriasum -latriamsadm -latriamntrpc -latriacm -latriavob -latriaview -latriacm -latriadbrpc -latriatirpc -latriaxdr -latriamvfs -latriatbs -latriaadm -latriasplit -latriacredmap -latriaks  -lezrpc  -lrpcsvc  -latriaccfs -latriasquidad  -latriasquidcore '
	    );
if ($os =~ /solaris/){
	my($esp_str,$esp_ver,$flag_rd);
	my $default_compiler = $Config{cc};	
    if( $default_compiler =~ /gcc/ || $ENV{CC_CTCMD_GCC}){
	$default_compiler = "gcc";
	$opts{CC} = $default_compiler;
	$opts{LD} = $default_compiler;
	$opts{OPTIMIZE} = '-O';
	$esp_str="gcc version";
	$esp_ver=2.7;
	$flag_rd = ' -v 2>&1';
    }elsif($default_compiler =~ /cc/){
	$esp_str="WorkShop Compilers";
	$esp_ver=4.2;
	$flag_rd = ' -V 2>&1';
    }else{
	die 'No default compiler';
    }
    if(-e '/usr/lib/libCrun.so.1'){
       if(!-e 'libCrun.so'){
	   if (!symlink('/usr/lib/libCrun.so.1','libCrun.so')){
	       die "/usr/lib/libCrun.so.1: $!";
         }
    }
    }else{
	die 'No libCrun.so.1 exist on the lib path';
    }
    die 'Cannot find  '.$default_compiler.' -> Sun Workshop Compilers 5.0 or gcc'  
	unless CheckVer($esp_str,$esp_ver,$default_compiler.$flag_rd);
    die "Cannot find ClearCase 4.1 or higher or cannot find $cleartool" 
	unless CheckVer('ClearCase version',4.1,$cleartool.' -ver',1);
    die "CtCmd requires Solaris 5.7 or higher"
	unless CheckVer("SunOS",5.7,'uname -sr');
    require 'SolarisInterposer'; 
    $opts{LIBS} =$opts{LIBS}.'  -lc  -lw -lCrun'." -R$ATRIA_ROOT/shlib";
    $opts{DEFINE}	= $opts{DEFINE}.'-DSVR4';
    $opts{INC}	= '-I. ';
    $opts{MYEXTLIB}='-lzuba';
    $opts{dynamic_lib} = { OTHERLDFLAGS => '-Lblib/arch/auto/ClearCase/CtCmd -t -ucmdsyn_proc_table  -R$(ATRIA_ROOT)/shlib  -R$(INSTALLSITEARCH)/auto/$(FULLEXT)  -R$(INSTALLSITELIB)/auto/$(FULLEXT) -R$(INST_ARCHLIB)/auto/$(FULLEXT) '} ;
}elsif ($os =~ /linux/){
    $opts{LD} = "ld";
    die 'Cannot find  '.$Config{cc}  
	unless CheckVer('version',2.7,$Config{cc}.' -v 2>&1')||
	    CheckVer('version egcs-',2.7,$Config{cc}.' -v 2>&1');
    die "Cannot find ClearCase 4.1 or higher or cannot find $cleartool" 
	unless CheckVer('ClearCase version',4.1,$cleartool.' -ver',1);
    $opts{DEFINE}= $opts{DEFINE}.'-DATRIA_LINUX';
    $opts{INC}='-I. ';
    $opts{LIBS} =$opts{LIBS}.' -lc -lcurses'; 
    $opts{dynamic_lib}={ OTHERLDFLAGS => ' -ucmdsyn_proc_table -rpath '.$ATRIA_ROOT.'/shlib:.:'.$inst_lib};
}elsif  ($os =~ /hpux/){

    my ($highenough,$ctver) = CheckVer('ClearCase version',4.1,$cleartool.' -ver',1);
    die "Cannot find ClearCase 4.1 or higher or cannot find $cleartool" unless $highenough;
    $osver = `uname -r`;chomp $osver;
    $osver =~ s/^[A-Z]\.//;print "OSVER $osver\n";
    $opts{LIBS} =  $opts{LIBS}.' -lperl -lperlDynaLoader ' if $ctver < 5;
    if ($osver == 10.20){
	print "HPUX-10.20\n";
	$opts{LIBS} =  $opts{LIBS}.'-lcurses -lM -lezrpc  -lrpcsvc -lsec -lstd -lstream -lcl -lc   -ldld ';
	$opts{DEFINE}= $opts{DEFINE}.'-DATRIA_HPUX10';
	$opts{dynamic_lib}={ OTHERLDFLAGS => ' +b: -E -lCsup'};
    }elsif(11 >= $osver && $osver < 12 ){
	print "HPUX-11\n";
	$opts{LIBS} =  $opts{LIBS}.'-lcurses -lM -lezrpc  -lrpcsvc -lsec -lstd -lstream -ldld -lCsup';
	$opts{dynamic_lib}={ OTHERLDFLAGS => ' +b: -E -l:libcl.0  -l:libc.0 '};
    }else{
    }
    $opts{MYEXTLIB}='cpprt0_stub.o';

}elsif  ($os =~ /MSWin32/){
    die 'Cannot find  '.$Config{cc}.' -> Microsoft (R) 32-bit C/C++ Optimizing Compiler Version 12'  
	unless CheckVer('Version',12,$Config{cc}.' 2>&1' );
    die "Cannot find ClearCase 4.2 or higher or cannot find cleartool in PATH" 
	unless CheckVer('ClearCase version',4.2,'cleartool -ver',1);
    $opts{CCFLAGS} = $Config{ccflags}.' -DATRIA_WIN32_COMMON';
    $opts{LIBS}='/defaultlib:cmdsyn.lib /defaultlib:ks.lib  "/defaultlib:WS2_32.LIB"';
    $opts{MYEXTLIB}='cmdsyn.lib ks.lib';
    $opts{LDDLFLAGS}=$Config{lddlflags};
    $opts{LDDLFLAGS} =~ s/-nodefaultlib//;
    require 'Win32C_O';
}elsif ($os =~ /AIX/i){
    die "Cannot find ClearCase 4.1 or higher or cannot find $cleartool" 
	unless CheckVer('ClearCase version',4.1,$cleartool.' -ver',1);
}else{print "Unsupported Platform\n"}


WriteMakefile(%opts);

sub CheckVer{
    my $expected_string = shift;
    my $level = shift;
    my $prog_output = shift;
    my $trailing = shift;
    $prog_output = `$prog_output`;
    $prog_output =~ /$expected_string\s*(\d+\.\d+\.?\d*)/i;
    $found_level = $1;
    if($trailing){
	$found_level =~ s/\d+\.(\d+\.\d+)/$1/;
    }else{
	$found_level =~ s/(\d+\.\d+)\.\d+/$1/;
    }
    my $ans = Found;
    $ans = 'Not Found' unless $1;
    print "Looking for $expected_string\t$level\t$ans\t$found_level\n";
    if ($found_level >= $level){
	return 1,$found_level
	}else{return $found_level,0}
}

