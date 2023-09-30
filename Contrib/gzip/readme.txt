USING THE EXTERNAL GZIP ^

If the external gzip is used, the following opens are used:

    open(FH, "gzip -dc $filename |")  # for read opens
    open(FH, " | gzip > $filename")   # for write opens