# Toybox
To learn a new language or new language feature, I often write undocumented, unpolished toys.
After some time away it is unclear what the code does or sometimes even how to run it.

This repo is an attempt to make toy code reproducable within reason.
At the very least to document how they once worked.

## Quick Start
```
npm install
```

Run a toy.
```
node toybox.js --file gawk/tree.awk
```
> GNU awk must be installed. Dependencies are intentionally unhandled.

## Arguments
The `gawk/tree.awk` toy has a configuration file of the same basename `gawk/tree.json` defining default arguments.
In this case, just a path to the input file for awk.

If we specify additional arguments, they are passed to the toy instead of the default ones.
```
node toybox.js --file gawk/tree.awk gawk/data/new-tree.txt
```

Passing arguments directly is convenient when iterating on a new toy but documenting them in a json file
makes execution reproducable.

## Pipelines
To reduce tedium and for documentation, `pipelines.js` defines steps needed to execute a toy based on its file extension.

For example, we might compile before every execution or we may forget the syntax of awk.
