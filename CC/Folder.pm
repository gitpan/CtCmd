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

CC::Folder - XXX

=cut

##############################################################################
package CC::Folder;
##############################################################################

# Folder is a subclass of VobObject.

@ISA = qw(CC::UCMObject);

use CC::CC;
use CC::UCMObject;
use CC::VobObject;
use CC::Activity;
use strict;
# use Trace;


##############################################################################
sub new
##############################################################################
{
    # my $trace();
    my $class  = shift @_;
    my $objsel = CC::CC::make_objsel('folder', @_);

    my $this   = new CC::VobObject($objsel);
    my $cleartool = ClearCase::CtCmd->new;
    my $status;
    $this->{cleartool}=$cleartool;
    $this->{status}=0;
    return bless($this, $class);
}

##############################################################################
sub create
##############################################################################
{
    # my $trace();
    my %args   = @_;
    my $parent = $args{parent};
    my $name   = $args{name};
    my $title  = $args{title};
    
    CC::CC::assert($parent);
    CC::CC::assert($name) unless $title;
    CC::CC::assert($title) unless $name;
    
    my $objsel ;
    $objsel = CC::CC::make_objsel('folder', $name, $parent->vob()) if $name;

    $title or $title = $name;
    my @title_args ;
    @title_args = ('-title', qq("$title")) if $title;

    my @cmd = ('mkfolder', '-nc', @title_args, '-in', $parent->objsel(), $objsel);

    my @rv = ClearCase::CtCmd::exec(@cmd);
    chomp $rv[1];
    if ($objsel){}
    else{
	$rv[1] =~ /folder\s+\"(.+?)\"/;
	$objsel = CC::CC::make_objsel('folder', $1,$parent->vob());
    }
    return $rv[0]? new CC::Folder($objsel) : 0;
}

##############################################################################
# this name "projects"  is inconsistent with the CC::Component::list() method
# for a method that has the same purpose and returns the same type  wjs

sub projects

##############################################################################
{
    # my $trace();
    my $this  = shift @_;

    my @objsels = split(' ', $this->describe('%[contains_projects]Xp'));

    return map { new CC::Project($_); } @objsels;
}

##############################################################################
sub folders
##############################################################################
{
    # my $trace();
    my $this  = shift @_;

    my @objsels = split(' ', $this->describe('%[contains_folders]Xp'));
    for (@objsels){s/\"//g}; #wjs
    return map { new CC::Folder($_); } @objsels;
}

##############################################################################
sub root_folder
##############################################################################
{
    # my $trace();
    my $vob   = shift @_;

    return new CC::Folder('RootFolder', $vob);
}

1;   # Make "use" and "require" happy
