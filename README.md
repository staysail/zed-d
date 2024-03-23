# D for Zed

This is a very preliminary extension for D.  It uses my Tree-Sitter grammar, and includes
syntax highlighting, folds, and outlines for semantic navigation.

We plan to add LSP support once the Zed team documents how to do that in an extension.

It would be nice to also add some task support if Zed provides a way for extensions to do that.

## Testing & Building

You need to build the WASM version of the Tree-Sitter grammar, and then put that in the grammars
folder, and then copy this repo into the appropriate extension folder.  Hopefully the Zed team
will make this a little more painless in the future.
