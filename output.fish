#! /usr/bin/fish 

if test (count $argv) -lt 2
	return 1
end

# Trim leading and trailing whitespaces
set -l output_lines (cat $argv[1] | string trim)
set -l answer_lines (cat $argv[2] | string trim)
set -l answer_len (count $answer_lines)
set -l output_len (count $output_lines)

set -l output_string (cat $argv[1] | string trim | string join '')
set -l answer_string (cat $argv[2] | string trim | string join '')
set -l max_len (math max $answer_len, $output_len)

# Putting $answer_string in "" is important so that it does not error out when it is empty
if test "$output_string" = "$answer_string"
	return 0
end

if test $max_len -gt 0
	printf "\n"
end

for i_max_len in (seq 1 $max_len)
	if test $i_max_len -le $output_len && test $i_max_len -le $answer_len
		if test $output_lines[$i_max_len] = $answer_lines[$i_max_len]
			
			set_color green
			printf "%d) " $i_max_len
			set_color normal
			
			printf "%s\n" $output_lines[$i_max_len]
		else
			set_color red
			printf "%d) " $i_max_len
			set_color normal
			
			printf "%s" $output_lines[$i_max_len]
			printf " | "
			printf "%s\n" $answer_lines[$i_max_len]
		end
	else if test $i_max_len -le $output_len
		set_color red
		printf "%d) + " $i_max_len
		set_color normal
			
		printf "%s\n" $output_lines[$i_max_len]
	else
		set_color red
		printf "%d) - " $i_max_len
		set_color normal
			
		printf "%s\n" $answer_lines[$i_max_len]
	end
end

printf "\n"

# The two files don't match
return 1
