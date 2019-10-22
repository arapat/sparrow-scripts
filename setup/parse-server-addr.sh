grep -o "ec2-[0-9\-]*" $1 | sed "s/ec2-//" | sed "s/-/\./g" > parsed_$1
