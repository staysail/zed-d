# D for Zed

This is a very preliminary extension for D. It uses my Tree-Sitter grammar, and includes
syntax highlighting, folds, and outlines for semantic navigation.

It would be nice to also add some task support if Zed provides a way for extensions to do that.

## Testing & Building

You need to build the WASM version of the Tree-Sitter grammar, and then put that in the grammars
folder, and then copy this repo into the appropriate extension folder. Hopefully the Zed team
will make this a little more painless in the future.

## Language Server Support

Basic LSP support for serve-d is here. It's not configurable yet.

## Licenses

The initial integration of support for Serve-D is based on the CSharp
extension for Zed (which is built into Zed). That original source
was provided under the Apache 2.0 terms, so that is released under the
same terms. The rest of this work (the queries, and the tree-sitter
integration) is all MIT licensed. These two licenses are mutually
compatible, so there shouldn't be an issue.
