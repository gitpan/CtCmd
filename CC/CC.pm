##########################################################################
#                                                                        #
# © Copyright IBM Corporation 2001, 2004. All rights reserved.           #
#                                                                        #
# This program and the accompanying materials are made available under   #
# the terms of the Common Public License v1.0 which accompanies this     #
# distribution, and is also available at http://www.opensource.org       #
# Contributors:                                                          #
#                                                                        #
# Matt Lennon - Creation and framework.                                  #
#                                                                        #
# William Spurlin - Maintenance and defect fixes                         #
#                                                                        #
##########################################################################

=head1 NAME

CC - XXX

=head1 SYNOPSIS


=head1 DESCRIPTION

CC.pm is a module for use when running "make test" during a build/test
of ClearCase::CtCmd.pm, and has no other use, implied or explicit.

=cut

##############################################################################
package CC::CC;
##############################################################################

use strict;
use CC::Vob;
#use Trace;
use ClearCase::CtCmd;


#xchen: modified for winNT
if($^O =~ /Win/){
    $CC::CC::tmp_dir = "\\WINNT\\Temp";
}else{
    $CC::CC::tmp_dir = '/var/tmp';
}

##############################################################################
sub make_objsel
##############################################################################
{
#    my $trace = new Trace();
    my ($oskind_hint, $name, $vob_hint) = @_;
    my $oskind;
    my $vob_tag;

    # Create canonical object selector.

    ($oskind, $name, $vob_tag) = parse_objsel($name);

    if ( ! $oskind) {
        $oskind_hint || die("No selector kind");
        $oskind = $oskind_hint;
    }

    if ( ! $vob_tag) {
        $vob_hint || die("No selector vob");
        $vob_tag = $vob_hint->tag();
    }

    return sprintf('%s:%s@%s', $oskind, $name, $vob_tag);
}

##############################################################################
sub parse_objsel
##############################################################################
{
#    my $trace = new Trace();
    my $os    = shift;
    my $oskind;
    my $name;
    my $vob;
    my @parts;
    
    # Create canonical object selector.

    if ((@parts = split(':', $os)) == 2) {
        ($oskind, $os) = @parts;
    }

    if ((@parts = split('@', $os)) == 2) {
        ($os, $vob) = @parts;
    }

    $name = $os;

    return($oskind, $name, $vob);
}

##############################################################################
sub assert
##############################################################################
{
    my $expr = shift;
    my ($pkg,$file,$line) = caller();

    $expr || die(sprintf("##### ASSERTION FAILED at line %d in %s (package %s)\n",
                         $line, $file, $pkg));
}

1;   # Make "use" and "require" happy
