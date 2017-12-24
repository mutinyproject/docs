# Mutiny
## A project to create an open-source operating system with no compromises.

Mutiny is a project to create a modern day open-source operating system that makes no compromises
in terms of software and philosophy. Less cruft, more flexibility, suitable for any purpose desired.

As of now it's based around the Linux kernel, [musl libc], and the LLVM toolchain. The init system
that we're starting with is [s6]+[s6-rc], but the goal is that the system will be as flexible as
possible and allow for any init system, any libc, any toolchain, and so on.

No Red Hat, no GNU, no group with all the power. An open system with the interests of the developers
and spirit of free development for the betterment of computing, rather than companies and
foundations vying for the most adoption and most marketable product.

## Design

- Allow for building from source and using binary packages through the same
  package manager.
- Use dynamic linking. Static linking more often than not increases the size
  of systems and creates a harder to secure and harder to maintain system.
- Be secure, harden the system whenever it is reasonable to do so.
- Support multiple build targets in an integrated way.
- Avoid clunky, legacy-ridden software in favor of forward-looking, slimmer
  alternatives.
- Adhere to a new philosophy, influenced by BSD hacker ethic and
  Linux-style openness.
    - Have spectacular documentation.
    - Use permissively licensed software. Code should be free to use by anyone,
      for anything, in any scenario.
    - There is no base, there are no "ports". Decentralized programs come
      together to create the user's system.

[musl libc]: https://www.musl-libc.org/
[s6]: https://skarnet.org/software/s6
[s6-rc]: https://skarnet.org/software/s6-rc
