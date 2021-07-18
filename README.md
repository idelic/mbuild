# mbuild

A modular, extensible, non-recursive build system implemented on top of GNU
make.

## Main features

- **Non-recursive**: The full build graph is available to `GNU Make` as a single
  in-memory makefile.

- **Sub-directory builds**: Build targets defined in a sub-directory in the same
  manner as you build the whole project, without any special options.

- **Full dependency tracking**: When you build a sub-directory, dependencies are
  still tracked for the whole project.

- **Variant builds**: Build for multiple configurations with one `make`
  invocation. Artifacts produced by each build are kept in separate
  locations.

- **Build flavors**: Build with different flags (e.g. for different
  architectures) and keep all generated files separate.

- **Configurable *out-of-date* checks**: Time stamps, command lines or file
  hashes. Or any combination of them!

- **Relocatable**: Sub-projects and their source files are located
  automatically. Add, move or rename directories or sources freely without
  touching the build system.

- **Distinction between *build* vs. *usage* requirements**: Each library 
  defines the compiler and linker flags that `users` of the library need to
  use.

- **Transitive properties**: All target requirements are *transitive* and
  propagate automatically via `pull` properties.

- **Introspection*: Query the dependency tree, examine all properties of
  targets, extract values of any build variable. No need to duplicate
  variables between configuration and build files, or pass values via the
  environment.

- **Flexible configuration**: Easily customize the build for each user or build machine.

