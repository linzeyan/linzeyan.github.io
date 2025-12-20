---
title: "Printing ASCII Art in the Shell"
date: 2022-10-21T17:30:41+08:00
menu:
  sidebar:
    name: "Printing ASCII Art in the Shell"
    identifier: linux-shell-printing-ascii-art
    weight: 10
tags: ["URL", "SHELL", "Linux", "ASCII"]
categories: ["URL", "SHELL", "Linux", "ASCII"]
hero: images/hero/linux.png
---

- [Printing ASCII Art in the Shell](https://www.baeldung.com/linux/shell-printing-ascii-art)

##### banner

> `sudo apt install sysvbanner`

```bash
$ banner hello

 #    #  ######  #       #        ####
 #    #  #       #       #       #    #
 ######  #####   #       #       #    #
 #    #  #       #       #       #    #
 #    #  #       #       #       #    #
 #    #  ######  ######  ######   ####
```

##### FIGlet: Frank, Ian, and Glenn's Letters

> `sudo apt install figlet`

```bash
$ figlet hello
 _          _ _
| |__   ___| | | ___
| '_ \ / _ \ | |/ _ \
| | | |  __/ | | (_) |
|_| |_|\___|_|_|\___/
```

- `-f` option and specify a font name for the output
- `-l`, `-c`, and `-r` options to align the text to the left, center, or right,

##### TOIlet: FIGlet With More Options

> `sudo apt install toilet`

```bash
$ toilet -f mini hello

|_   _  | |  _
| | (/_ | | (_)
```

- `-F` filters

```bash
toilet -F list
Available filters:
"crop": crop unused blanks
"gay": add a rainbow colour effect
"metal": add a metallic colour effect
"flip": flip horizontally
"flop": flip vertically
"180": rotate 180 degrees
"left": rotate 90 degrees counterclockwise
"right": rotate 90 degrees clockwise
"border": surround text with a border
```

```bash
$ toilet -F border hello
┌───────────────────────────────────┐
│                                   │
│ #             ""#    ""#          │
│ # mm    mmm     #      #     mmm  │
│ #"  #  #"  #    #      #    #" "# │
│ #   #  #""""    #      #    #   # │
│ #   #  "#mm"    "mm    "mm  "#m#" │
│                                   │
│                                   │
└───────────────────────────────────┘
```

##### Making Cows Say Things With cowsay

> `sudo apt install cowsay`

```bash
cowsay hello
 _______
< hello >
 -------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

```bash
# `-g`, `-d`, and `-p` for greedy, dead, and paranoid cows
cowsay -d hello
 _______
< hello >
 -------
        \   ^__^
         \  (xx)\_______
            (__)\       )\/\
             U  ||----w |
                ||     ||


# use any characters of our choice for the eyes and the tongue by using the `-e` and the `-T` flags
cowsay -e oO -T V hello
 _______
< hello >
 -------
        \   ^__^
         \  (oO)\_______
            (__)\       )\/\
             V ||----w |
                ||     ||


# Using Other Animals and Creatures
cowsay -l
Cow files in /usr/share/cowsay/cows:
apt bud-frogs bunny calvin cheese cock cower daemon default dragon
dragon-and-cow duck elephant elephant-in-snake eyes flaming-sheep fox
ghostbusters gnu hellokitty kangaroo kiss koala kosh luke-koala
mech-and-cow milk moofasa moose pony pony-smaller ren sheep skeleton
snowman stegosaurus stimpy suse three-eyes turkey turtle tux unipony
unipony-smaller vader vader-koala www


cowsay -f duck hello
 _______
< hello >
 -------
 \
  \
   \ >()_
      (__)__ _
```

###### Using cowsay With fortune/lolcat

```bash
fortune | cowsay
 ____________________________________
/ Try to relax and enjoy the crisis. \
|                                    |
\ -- Ashleigh Brilliant              /
 ------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

##### Printing Images With jp2a

> `sudo apt install jp2a`

```bash
jp2a baeldung.png


                                      d.
                                   'kNM;
                               'l0MMMMMo
                       ::ldkKKMMMMMMMMM;
                  :dKNMMMMMMMMMMMKMMMMM.
                lNMMMMMMMMMMMMMO'MMMMMM
               xMMMMMMMMMMMMMMd kMMMMMO
              .MMMMMMMMMMMMMc  ;MMMMMM.
              KMMMMMMMMMMMk   ,MMMMMMk
              NMMMMMMMMMl   .KMMMMMMW
              KMMMMMMW     :MMMMMMMM
              xMMMMM.     0MMMMMMMM.
          ':dKMMK      .dNMMMMMMM.
      dKKMMMd        lKMMMMMMMN
                   .kWMMM0;
```

We can also use the -colors flag to obtain colored output
