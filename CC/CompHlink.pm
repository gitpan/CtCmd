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

CC::CompHlink - XXX

=cut

##############################################################################
    package CC::CompHlink;
##############################################################################

# CompHlink is a subclass of VobObject

@ISA = qw(CC::VobObject);

use CC::CC;
use CC::VobObject;
use CC::AdminVob;
use strict;
# use Trace;

##############################################################################
sub new
##############################################################################
{
    # my $trace();
    my $class  = shift;
    my $objsel = shift;
    my $this   = new CC::VobObject($objsel);
    my $cleartool = ClearCase::CtCmd->new;
    my $status;
    $this->{cleartool}=$cleartool;
    $this->{status}=0;
    return bless($this, $class);
}

##############################################################################
sub adminvob
##############################################################################
{
    # my $trace();
    my $this  = shift;
    my $val = $this->{cleartool}->exec('des','-fmt','%Xn','-ahlink','AdminVOB','vob:'.$this->vob()->tag());
# wjs returns AdminVob.
    $this->{status} = $this->{cleartool}->status;
    return  CC::AdminVob->new($1) if $val =~ /-\> vob\:(.*)/ ;
    return 0;
}

1;   # Make "use" and "require" happy

