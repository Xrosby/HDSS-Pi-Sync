


get_full_name () {
    read -p "What is your firstname?    " firstname
    read -p "What is your lastname?    " lastname

    read -p "Are you sure your name is ${firstname} ${lastname}? (y/n)" answer
    if [$answer == "y"]
    then 
        echo "Hello ${firstname}"
    else 
        get_full_name
}

get_full_name