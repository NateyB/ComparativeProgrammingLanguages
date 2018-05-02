my @uString = [97,98,99];
my @oString = [100];

sub union {
    my %hash;
    for (@_) {
        for my $item (@$_) {
	    $hash{$item} = 0;
        }
    }
    wantarray ? keys %hash : join(',', keys %hash);
}

@hi = union (@uString, @oString);
$bye = union (@uString, @oString);
#print "@hi \n $bye\n";
