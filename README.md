# D for Zed

This is an extension for D. It uses my Tree-Sitter grammar, and includes
syntax highlighting, folds, and outlines for semantic navigation.

It optionally utilizes [_serve-d_](https://github.com/Pure-D/serve-d) for additional language support.

## Testing & Building

Just use the `zed: install dev extension` command on a directory containing a checkout of this repository.

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
