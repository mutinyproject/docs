# Design
## Details, overview, and other notes about the design of a theoretical Mutiny system.

Mutiny is a project inspired by multiple different Linux distributions, software made in
response to system hegemony, embedded systems, interest in BSD-styles of design, and an
interest in forward-thinking system design. Systems can be integrated, be well put together,
and allow for deviance.

Systems should carry as little legacy, and give as little bend to the popular software
and development groups as possible. Open standards exist for this very reason, to give
us the ability to create diversity in the computer world while preserving the ability to
maintain a level of interoperability with systems of other origin, ideology, and reasoning.

Decentralize. Using software from one development group means you become beholden to the
interests of that group, and it promotes vendor lock-in; the clearest example of this
would be how much the state of the Unix desktop and server has changed because of the
choices that GNOME, RedHat, etc. have made.

We live in a time where systems are changing rapidly, and the possibilities of system design
are changing in new exciting ways. Mutiny is a response to this, an attempt to carry out
the perfect concept of a modern Unix system with attention paid at every level.

Aim to support any use case worth supporting: desktop, server, small devices, containers.

## System

### Software base

- Avoid GNU software when a viable alternative exists
    - Best example: GCC vs Clang
- Prefer software with less legacy, unless legacy is required
    - `ncurses` vs. `netbsd-curses`?
- Slim software whenever it is possible.
- Package base
    - `musl`
    - `fortify-headers`
    - `clang`
    - `libc++`
    - `libressl`
    - `mandoc`
    - `toybox`
        - `busybox` to fill in the cracks, temporarily
    - `mksh`
        - The long-term plan is to switch to the [Oil shell](#Oil shell) once it is fully functional
    - `s6`, `s6-rc`

#### Oil shell

[Oil] is a new Unix shell that aims to both be able to run scripts for `bash`, POSIX sh, etc., as
well as implement and define a new shell language that fixes a lot of problems in shell scripting.
The idea is that it will superscede `bash`, treating shell scripting as a serious language that
things can be written in.

Things like data types, actual *real* functions, well implemented arrays, those will be in Oil.

As it stands I'm just waiting for it to be fleshed out more.

[Oil]: https://www.oilshell.org/

### System administration

The state of system administration nowadays can be very fragmented. Most people just search
for the documentation online nowadays, finding the manuals to be lacking, or just too archaic.

However, you will notice this is rarely a problem with *BSD systems. This is because BSD systems,
historically, have put more emphasis on good documentation of their systems. Every single aspect
of the kernel's internals, drivers, quirks, etc., is documented in a manpage.

On a large scale, this unity in the system is what Mutiny is striving for. Linux systems have had
a tendency to be disjointed at times, as the model which the system is developed in doesn't usually
correspond to the stewardship that comes with the tightly-managed attitude of something like OpenBSD.

Where we can best improve this is in the administration of a system.

->**TODO: elaborate with references to s6, s6-rc, user instances, etc.**<-

### Mutiny utilities

- `riot` - a source-based and binary-based package manager
- `synonym` - a utility for managing alternatives

### Filesystem layout

```text
/   - Also the root user's home directory.
    /boot               - Boot files
    /dev                - Device files (devtmpfs)
    /etc                - Configuration
    /home               - User files
    /host -> ${CHOST}   - Symlink to default CHOST
    /local              - System-specific files (not managed by packages)
        /local/share    - User-managed resources. (separate, not arch-specific)
    /mnt            - Mounted devices
    /proc           - Process/system information (procfs)
    /run            - Runtime files (non-persistent), such as... (tmpfs)
        /run/tmp        - Temporary files
    /share          - Documentation, other resources
    /src            - Source (kernel things, usually)
    /srv            - Service data (httpd, git-daemon)
    /sys            - System/kernel information (sysfs)
    /var            - Variable files (persistent), such as...
        /var/cache      - Caches
        /var/log        - Logs
        /var/lib        - State files maintained by programs
        /var/spool      - Spools maintained by programs (crond, cups, etc)
        /var/tmp        - Temporary files not cleared at boot
    /${CHOST}   - Directories containing ${CHOST}-only files (bins/libs)
        /bin            - Binaries
        /include        - Header files for libraries
        /lib            - Libraries, internal binaries for other programs
        /local/bin      - User-managed binaries
        /local/include  - User-managed header files
        /local/lib      - User-managed libraries, internal binaries
```

There's also some symlinks so we don't have to wrestle with other software...

```text
/
    /bin            -> host/bin
    /lib            -> host/lib
    /lib64          -> host/lib64               - Only on x86_64 hosts
    /local/bin      -> ../host/local/bin
    /local/include  -> ../host/local/include
    /local/lib      -> ../host/local/lib
    /local/sbin     -> ../host/local/sbin
    /media          -> mnt
    /sbin           -> host/sbin
    /tmp            -> run/tmp
    /usr            -> .
    /var/run        -> ../run
```

## Package design

- Reasonable command line interface
- Run (inexpensive) tests by default
- Libraries
    - See: Gentoo's eclasses, Exherbo's exlibs
- Useful metadata
    - Build dependencies vs. runtime dependencies
    - Licenses
    - Links to documentation

## Prior art

- Exherbo Linux
- OpenBSD
- Sabotage Linux
- Void Linux
- Stali
- Morpheus Linux

## Recommended reading

- [OpenBSD's project goals](https://www.openbsd.org/goals.html)
- [OpenBSD's copyright policy](https://www.openbsd.org/policy.html)
- [Rob Landley at the Embedded Linux Conference 2013, discussing `toybox`](https://www.youtube.com/watch?v=SGmtP5Lg_t0)
- [Rob Landley at the Embedded Linux Conference 2015, more `toybox` discussion](https://www.youtube.com/watch?v=04XwAbtPmAg)
- [Rob Landley at Ohio LinuxFest 2013](https://archive.org/details/OhioLinuxfest2013/24-Rob_Landley-The_Rise_and_Fall_of_Copyleft.flac)
- [Ted Nelson's Computer Paradigm](http://hyperland.com/TedCompOneLiners)

