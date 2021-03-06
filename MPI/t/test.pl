use strict;
use warnings;
use Cwd qw(cwd);
use lib cwd() . '/..';
use lib cwd() . '/../..';
use MPI::Simple;

MPI::Simple::Init();
my $mocking = MPI::Simple::Mocking();
my $rank = MPI::Simple::Comm_rank();
if ($rank == 1 || $mocking) {
	MPI::Simple::Send({'data'=>[17],'name'=>'moo'}, 0, 123);
}

if($rank == 0) {
	my $sender;
	my $msg = MPI::Simple::Recv(1, 123, \$sender);
	if(
		(ref $msg eq ref {}) &&
		(ref $msg->{'data'} eq ref []) &&
		@{$msg->{'data'}}[0] == 17 &&
		$msg->{'name'} eq 'moo' &&
		($mocking || $sender == 1)
	) {
		print "test1: PASSED\n";
	} else {
		print "test1: FAILED\n";
		use Data::Dumper;
		print Dumper($msg), "\nsender = $sender\n";
	}
}

if(MPI::Simple::Comm_size() > 1) {
	my $error = $rank == 0;
	$error = MPI::Simple::Error($error);
	
	if($rank == 1) {
		if($error == 1) {
			print "test2: PASSED\n";
		} else {
			print "test2: FAILED\n";
		}
	}
}
MPI::Simple::Finalize();
