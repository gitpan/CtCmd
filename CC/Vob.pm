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

=head1 NAME

CC::Vob - XXX

=cut

##############################################################################
package CC::Vob;
##############################################################################

use CC::CC;
# use Trace;
use strict;

%CC::Vob::tag_cache = ();

##############################################################################
sub create
##############################################################################
{
    # my $trace();
    my %args    = @_;
    my $is_svob = $args{cc}   =~ /true|yes/i;
    my $mount   = $args{mount} !~ /false|no/i;
    my @cmd;
    my @opts;

    CC::CC::assert($args{tag});

    # Set up command.

    my $tag = sprintf("%s/smoke.%s.%d", $CC::CC::tmp_dir, $args{tag}, $$);
    my $stg = "$tag.vbs";

    $is_svob and push(@opts, '-cc');
    @cmd = ('mkvob', '-nc', @opts, '-tag', $tag, $stg);

    # Create VOB.

    my ($status,$out,$err) = ClearCase::CtCmd::exec(@cmd);
    print("$out $tag"); # print the first line - "Created VOB ..."

    my $vob = new CC::Vob($tag);

    # Mount VOB.

    if ($mount) {
	#xchen: handle win32
	if($^O !~/Win/){
	    system('/bin/mkdir', $vob->tag()) && die("Can't create VOB mount dir");
	}
        ClearCase::CtCmd::exec('mount', $vob->tag());
    }

    return $status? 0 : $vob;
}

##############################################################################
sub new
##############################################################################
{
    # my $trace();
    my $class = shift;
    my $id    = shift;
    my $this  = { };

    # Get VOB's tag from our tag cache if possible, else use 'describe'.

    if ( ! exists($CC::Vob::tag_cache{$id})) {
        $CC::Vob::tag_cache{$id} = ClearCase::CtCmd::exec('des', '-fmt', '%n', "vob:$id");
    }

    $this->{tag} = $CC::Vob::tag_cache{$id};
    my $cleartool = ClearCase::CtCmd->new;
    $this->{cleartool}=$cleartool;
    $this->{status} = 0;
    return bless($this, $class);
}

##############################################################################
sub DESTROY
##############################################################################
{
    return 1; # no-op
}

##############################################################################
sub tag
##############################################################################
{
    # my $trace();
    my $this  = shift;

    return $this->{tag};
}

##############################################################################
sub family_oid
##############################################################################
{
    my $this = shift @_;

    CC::CC::assert($this);

    if ( ! $this->{foid}) {
        my $tag = $this->tag();
        $this->{foid} = $this->{cleartool}->exec('des -fmt %On', "vob:$tag");
    }

    return  $this->{cleartool}->status? 0 : $this->{foid};
}

##############################################################################
sub equals
##############################################################################
{
    my $this = shift @_;
    my $that = shift @_;

    CC::CC::assert($this && $that);

    # XXX Comparing vob oids would be more correct.
    return($this->tag() eq $that->tag());
}

1;   # Make "use" and "require" happy
