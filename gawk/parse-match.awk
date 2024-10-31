# Extract part of the matched field

BEGIN {
    FS=",";
    name = "";
    regex = "Some fixed string [a-z0-9]+";
}

match($1, regex) {
    name = substr($1, RSTART+18, RLENGTH);
}

$2 {
    print name " has status " $2;
}
