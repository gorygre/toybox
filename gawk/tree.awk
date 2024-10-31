# expects input to look like
# parent-id,child-id,node-data
# where the root has parent-id: 0

BEGIN {
    FS = ",";
    rootID = 0;
    nodePrefix = "|-- ";
    leafPrefix = "`-- ";
    red     = "\033[1;31m";
    green   = "\033[1;32m";
    yellow  = "\033[1;33m";
    noColor = "\033[0m ";

    # awk -v "color=false" -f tree.awk # to turn off colored output
    if (color != "false")
    {
        color = "true";
    }
}

function setLast(item, array, depth) {
    for (items in array)
    {
        last = items;
    }

    if (last == item)
    {
        isLast = "true";
        depths[depth+1] = "false";
    }
    else
    {
        isLast = "false";
        depths[depth+1] = "true";
    }
}

function indent(depth) {
    string = "";

    for (indentIndex = 1; indentIndex <= depth; indentIndex++)
    {
        if (depths[indentIndex] == "true")
        {
            string = string "|    ";
        }
        else
        {
            string = string "     ";
        }
    }

    return string;
}

function printNode(name, depth) {
    printf indent(depth);

    if (isLast == "true")
    {
        printf leafPrefix;
    }
    else
    {
        printf nodePrefix;
    }

    print name;
}

function printChildren(parent, depth) {
    depth++;
    if (isarray(tree[parent])) {
        for (child in tree[parent]) {
            setLast(child, tree[parent], depth);
            printNode(tree[parent][child], depth);
            printChildren(child, depth);
        }
    }
}

# you could further restrict this to add nodes selectively
$1 !~ /^#/ {
    # if node-data is some single value
    tree[$1][$2] = $3;

    # if node-data is an array of some kind:
    # len = lens[$1][$2]++;
    # tree[$1][$2][len] = $3;

    # if node-data is an struct of some kind:
    # size[$1][$2] = $3;
    # type[$1][$2] = $4;
    # color[$1][$2] = $5;
}

END {
    printChildren(rootID, -1);
}
