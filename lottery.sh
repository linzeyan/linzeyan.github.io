#! /bin/bash
printf "how many times？"
read n
echo 
echo
echo "******$n times******"
for ((i=1;i<=$n;i++))
do
a=$(($RANDOM%42+1))
b=$(($RANDOM%42+1))
c=$(($RANDOM%42+1))
d=$(($RANDOM%42+1))
e=$(($RANDOM%42+1))
f=$(($RANDOM%42+1))

	until [  "$a" -ne "$b" ]
	do
		until [  "$a" -ne "$c" ]
		do
			until [  "$a" -ne "$d" ]
			do
				until [  "$a" -ne "$e"]
				do
					until [  "$a" -ne "$f" ]
					do
						until [  "$b" -ne "$c" ]
						do
							until [  "$b" -ne "$d" ]
							do
								until [  "$b" -ne "$e" ]
								do
									until [  "$b" -ne "$f" ]
									do
										until [  "$c" -ne "$d" ]
										do
											until [  "$c" -ne "$e" ]
											do
												until [  "$c" -ne "$f" ]
												do
													until [  "$d" -ne "$e" ]
													do
														until [  "$d" -ne "$f" ]
														do
															until [  "$e" -ne "$f" ]
															do
															a=$(($RANDOM%42+1))
															b=$(($RANDOM%42+1))
															c=$(($RANDOM%42+1))
															d=$(($RANDOM%42+1))
															e=$(($RANDOM%42+1))
															f=$(($RANDOM%42+1))
															done
														done
													done
													
												done
											done
										done
									done
								done
							done
						done
					done
				done
			done
		done
	done

echo $a $b $c $d $e $f
done
echo "********************"
