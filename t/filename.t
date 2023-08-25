use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PostText');

$t->get_ok('/thread/single/1.txt')->status_is(200)
    ->header_like('Content-Disposition' => qr/filename=thread_1\.txt/);
$t->get_ok('/thread/single/1')->status_is(200)
    ->header_unlike('Content-Disposition' => qr/filename=thread_1\.txt/);

$t->get_ok('/remark/single/1.txt')->status_is(200)
    ->header_like('Content-Disposition' => qr/filename=remark_1\.txt/);
$t->get_ok('/remark/single/1')->status_is(200)
    ->header_unlike('Content-Disposition' => qr/filename=remark_1\.txt/);

done_testing;
