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

CC::Element - XXX

=cut

##############################################################################
package CC::Element;
##############################################################################

# Element is a subclass of File (was VobObject) wjs

@ISA = qw(CC::File);

use CC::CC;
use CC::File;
use CC::Version;
use CC::VobObject;
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
    $this->{status} = 0;
    return bless($this, $class);
}

##############################################################################
sub full_path
##############################################################################
{
    # my $trace();
    my $this  = shift;

    return $this->describe('%Xn');
}

##############################################################################
sub version
##############################################################################
{
    # my $trace();
    my $this  = shift;
    my $version_selector=shift;
    $version_selector=$this->objsel() unless $version_selector;
    return CC::Version->new($version_selector);

}


1;   # Make "use" and "require" happy
