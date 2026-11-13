# D for Zed

This is an extension for D. It uses my Tree-Sitter grammar, and includes
syntax highlighting, folds, and outlines for semantic navigation.

It optionally utilizes [_serve-d_](https://github.com/Pure-D/serve-d) for additional language support.

## Testing & Building

Just use the `zed: install dev extension` command on a directory containing a checkout of this repository.

### Highlighting regression tests

The highlighting tests require Node.js 18 or later, Tree-sitter CLI 0.27.2, and
a C compiler supported by the CLI (for example, Visual Studio Build Tools on
Windows). Check out the grammar revision pinned in `extension.toml`:

```sh
git clone https://github.com/gdamore/tree-sitter-d.git ../tree-sitter-d
git -C ../tree-sitter-d checkout 64f27931b4e6fdd75af1102c79bacbca68a8dacc
node tests/highlighting/test-highlights.cjs tree-sitter ../tree-sitter-d
```

Replace `tree-sitter` with the executable's path if it is not on your `PATH`.
The runner prepares CLI metadata in a temporary directory without modifying
the grammar checkout. It rejects parse errors, compiles the complete query,
and checks the winning captures at the fixture's annotated source positions.
The fixture tests syntax highlighting, not D type checking or linking.

Calls, types, declarations, parameters, attributes, constants, documentation,
and interpolation have dedicated captures. As with Zed's Rust queries,
uppercase-type and all-caps-constant naming conventions provide fallbacks;
structural captures override these conventions. The D grammar can represent
`object.method()` and `module.function()` identically, so both use method-call
captures. Distinguishing those cases and resolving imported symbols requires
semantic information. Themes determine the final visible colors.

## Language Server Support

Basic LSP support for _serve-d_ is here. Configuration is done in the Zed settings, using
a `serve-d` key under the `lsp` settings.  For example, this represents the settings we use
on a project at my employer:

```json
{
  "lsp": {
    "serve-d": {
      "settings": {
        "d": {
          "enableFormatting": false,
          "enableDubLinting": false,
          "manyProjectsThreshold": 20,
          "argumentSnippets": true,
          "scanAllFolders": false,
          "lintOnFileOpen": "project"
        },
        "dscanner": {
          "ignoredKeys": ["dscanner.style.long_line"]
        }
      },
      "binary": {
        "path": "/Users/garrett.damore/Projects/serve-d/serve-d"
      }
    }
  }
}
```

## Licenses

The initial integration of support for Serve-D is based on the CSharp
extension for Zed (which is built into Zed). That original source
was provided under the Apache 2.0 terms, so that is released under the
same terms. The rest of this work (the queries, and the tree-sitter
integration) is all MIT licensed. These two licenses are mutually
compatible, so there shouldn't be an issue.
