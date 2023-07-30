#! /usr/bin/fish 

set -l sig_name $argv[1]
# Check if $sig_name is a number
if string match -qr '^-?[0-9]+(\.?[0-9]*)?$' -- "$sig_name"
	set sig_name (fish_status_to_signal {$sig_name})
else
	set sig_name (string upper $sig_name)
end

switch $sig_name
case SIGHUP
	printf "[%s] Hang up\n" $sig_name
case SIGINT
	printf "[%s] Interrupted\n" $sig_name
case SIGQUIT
	printf "[%s] Quit\n" $sig_name
case SIGILL
	printf "[%s] Illegal instruction\n" $sig_name
case SIGTRAP
	printf "[%s] Trap\n" $sig_name
case SIGABRT
	printf "[%s] Abort\n" $sig_name
case SIGBUS
	printf "[%s] Bus erro\n" $sig_name
case SIGFPE
	printf "[%s] Floating point exception\n" $sig_name
case SIGKILL
	printf "[%s] Kill\n" $sig_name
case SIGUSR1
	printf "[%s] Reserved for User(developer)\n" $sig_name
case SIGSEGV
	printf "[%s] Segmentation fault\n" $sig_name
case SIGUSR2
	printf "[%s] Reserved for User(developer)\n" $sig_name
case SIGPIPE
	printf "[%s] Broken pipe\n" $sig_name
case SIGALRM
	printf "[%s] Alarm\n" $sig_name
case SIGTERM
	printf "[%s] Terminate"\n  $sig_name
case SIGSTKFLT
	printf "[%s] Stack fault\n" $sig_name
case SIGCHLD
	printf "[%s] Child process died\n" $sig_name
case SIGCONT
	printf "[%s] Continues it\n" $sig_name
case SIGSTOP
	printf "[%s] Stops it\n" $sig_name
case SIGTSTP
	printf "[%s] Terminal stop\n" $sig_name
case SIGTTIN
	printf "[%s] Signal: TTY input\n" $sig_name
case SIGTTOU
	printf "[%s] Signal: TTY ouput\n" $sig_name
case SIGURG
	printf "[%s] Urgent\n" $sig_name
case SIGXCPU
	printf "[%s] Exceeded CPU limit\n" $sig_name
case SIGXFSZ
	printf "[%s] Exceeded file size limit\n" $sig_name
case SIGVTALRM
	printf "[%s] Alarm\n" $sig_name
case SIGPROF
	printf "[%s] Alarm\n" $sig_name
case SIGWINCH
	printf "[%s] Window resized\n" $sig_name
case SIGIO
	printf "[%s] Signal: Input/Output\n" $sig_name
case SIGPWR
	printf "[%s] Power failure\n" $sig_name
case SIGSYS
	printf "[%s] Signal system call\n" $sig_name
case '*'
	if string match -qr '^-?[0-9]+(\.?[0-9]*)?$' -- "$argv[1]"
		printf "[%s] Exit code\n" $argv[1]
	end
end
