#!/usr/bin/env bash

INPUT="4E6576657220676F6E6E61206769766520796F752075700A4E6576657220676F6E6E61206C657420796F7520646F776E"

main() {
    echo "Inspired by this perl one-liner:"
    echo "https://chaos.social/@xtaran/112750500318474871"
    echo
    echo "Which in turn was intended to decode this sticker:"
    echo "https://hsnl.social/@Dany/112749585364094383"
    echo
    echo "The correct input looks like:"
    echo "$INPUT"
    echo
    echo "First, the original perl implementation:"
    type perl_oneliner
    echo
    echo "It produces this output:"
    echo "$INPUT" | perl_oneliner
    echo
    echo "We can use basically the same technique in ruby:"
    type ruby_oneliner
    echo
    echo "$INPUT" | ruby_oneliner
    echo
    echo "In awk, we use the concept of records instead of a regex loop:"
    type awk_oneliner
    echo
    echo -n "$INPUT" | awk_oneliner
    echo
    echo
    echo "Now, python doesn't quite fit on one line:"
    type python_oneishliner
    echo
    echo -n "$INPUT" | python_oneishliner
    echo
    echo
    echo "We can also do this in pure bash:"
    type bash_oneliner
    echo
    echo -n "$INPUT" | bash_oneliner
    echo
    echo
    echo "For more comments and explanations, or to see the bash one liner"
    echo "actually on a single line, take a look at the source of this script"
    echo "in $0."
}

perl_oneliner() {
    # I've kept the `i` substitution option from the original post
    # even though I couldn't see it doing anything useful when I
    # experimented. The docs (`perldoc perlre`) say it means "case
    # insensitive", which seems like a good idea, even if _this_ input
    # is all-caps.
    perl -pE 's/[A-F0-9]{2}/ chr(hex($&)) /gei'

    # So far as I can tell, the `-E` could just as easily be `-e`, and
    # is similar to awk. It means execute the following string as your
    # main program.
    #
    # The -p, according to this post adds an implicit read-loop and
    # print statement into the program. We're not using all its power
    # here, since we've only one line of input, but the read and print
    # definitely save us some characters.
    #
    # Since we have that implicit read-print-loop, the main program is
    # a simple transformation, performed with a single perl-regex. The
    # regex option `g` means we'll match multiple times, so the regex
    # itself implicitly loops through our whole input line. The regex
    # option `e` means we can call perl functions in the output of the
    # substitution.
    #
    # The two functions we call are `hex`, which transforms a pair of
    # ASCII characters into a number, presuming that they can be read
    # that way; and `chr` which turns that number back into an ASCII
    # character.
    #
    # If `hex` is passed a string which can't be read as a hex number,
    # it just returns its input. If `chr` is passed a string instead
    # of a number, it just returns its input. So if you mess up your
    # input, and accidentally throw a few `Z`s in there, those `Z`s
    # will just be passed straight through and won't interfere with
    # the rest of the transformation.
    #
    # This makes the perl and ruby implementations the only ones in
    # here that don't need me to pass the `-n` flag to my initial
    # `echo` command, so that I don't have to worry about mangling
    # newlines.
}


ruby_oneliner() {
    ruby -pe 'gsub(/../) {|chr| sprintf("%c", chr.to_i(16))}'

    # This is basically the same as the perl implementation. We get an
    # implicit read-print-loop from the `-p` flag, and we use the
    # global regex substitution `gsub` to do the real loop over the
    # data.
    #
    # Like the perl implementation, I don't need the `-n` flag in my
    # initial echo, because this passes newlines straight through.
}

awk_oneliner() {
    awk -e 'BEGIN {RS=".."} ; {printf "%c", strtonum(sprintf("0X%s",RT))}'

    # This is a bit longer than the perl equivalent, but feels more
    # UNIXey to me. Even though I'm using a GNU-only regex record
    # separator.
    #
    # First, we set the record separator to the regex `..` so that the
    # rest of the program will loop over the input two characters as a
    # time. This is a bit cheeky, because if every input character
    # matches our record separator, then every record will be
    # empty. Fortunately for us, in the awk main loop, awk will allow
    # us to access the record terminator (`RT`) of the record, as well
    # as the record itself (`$0`).
    #
    # So, for each record, we print a transformation of the record
    # terminator (`RT`) of that record. This transformation is as
    # follows:
    #
    # First, prepend the string `0X` to it using `sprintf`
    # Next, transform it into a number using `strtonum`.
    #       (since it begins with a `0X`, it will be interpreted as
    #        hex)
    # Finally print the number as an ASCII character using `printf`
    #
    # My only anoyance with this one is that it mangles the final
    # newline character. But at least it doesn't error out.
}

python_oneishliner() {
    python3 -c 'import sys
input=sys.stdin.read()
i = 0
while i < len(input):
  print("%c" % int(input[i:i+2],16), end="")
  i = i+2'

    # Not really a "one liner" is it? Maybe a proper python programmer
    # can do better.
    #
    # Maybe easier to read?
    #
    # Python's stricter typing can be useful while writing longer
    # programs, but adds noise to the intent of this oneliner. It
    # means we need to be explicit about the newline case or the
    # program throws a big distracting error.
}

bash_oneliner() {
    while read -r -n 2 char ; do echo -en "\x${char}" ; done

    # Ok, this one is my fave. Bash has native understanding of hex
    # strings in its '\x' syntax, and can natively read input 2
    # characters at atime with `read -n 2`.
    #
    # It's still more characters than the perl one, but I think it's
    # way more readable. Also, it's "just bash".
}

main "${@}"
