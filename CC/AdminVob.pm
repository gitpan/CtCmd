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

CC::AdminVob - XXX

=cut

##############################################################################
package CC::AdminVob;
##############################################################################

# AdminVob is a subclass of  Vob

@ISA = qw(CC::Vob);


use CC::CC;
use CC::Vob;
use strict;
# use Trace;

sub root_folder{
    # my $trace();
    my $this   = shift;

    return new CC::Folder('RootFolder', $this);
}



##############################################################################
sub list
##############################################################################
{
    # my $trace();
    my $this   = shift;

    # List components in the specified VOB.  Convert each component
    # object selector into a CC::Component object.

    my $aa = $this->{cleartool}->exec("lscomp", "-fmt", '%Xn\n', "-invob", $this->tag());
    my @objsels = split /\n/,$aa;
    return  $this->{cleartool}->status? 0 : map { new CC::Component($_); } @objsels;
}



1;
