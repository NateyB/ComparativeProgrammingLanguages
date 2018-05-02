sub union{for(@_){my%h;for$i(@$_){$h{$i}=0}}wantarray?keys%h:join',',keys%h}
