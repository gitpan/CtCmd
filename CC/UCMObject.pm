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

CC::UCMObject - XXX

=cut

##############################################################################
package CC::UCMObject;
##############################################################################

# UCMObject is a subclass of  VobObject

@ISA = qw(CC::VobObject);


use CC::CC;
use CC::VobObject;
use strict;
# use Trace;


##############################################################################
sub title
##############################################################################
{
    # my $trace();
    my $this  = shift @_;
    my $title;

    CC::CC::assert($this);

    return $this->describe('%[title]p');
}


##############################################################################
sub name 
##############################################################################

# See "ct man fmt_ccase" .  wjs.
# Overrides VobObject::name()


{
    # my $trace();
    my $this  = shift @_;
    my $title;

    CC::CC::assert($this);

    return $this->describe('%Ln');
}




1;
