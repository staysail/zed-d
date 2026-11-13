; highlights.scm
;
; Highlighting queries for D code for use by Tree-Sitter.
;
; Copyright 2024 Garrett D'Amore
;
; Distributed under the MIT License.
; (See accompanying file LICENSE.txt or https://opensource.org/licenses/MIT)
; SPDX-License-Identifier: MIT

(string_literal) @string
(int_literal) @number
(float_literal) @number
(char_literal) @string
(identifier) @variable

; Like Rust, use naming conventions only as a fallback. Structural rules
; below take precedence (e.g. an uppercase parameter is still a parameter).
((identifier) @type
  (#match? @type "^[A-Z]"))
((identifier) @constant
  (#match? @constant "^_*[A-Z][A-Z0-9_]*$"))

; Modules and qualified types. Do not color every identifier inside a type:
; array sizes, template values and function parameters are expressions.
(module_fqn (identifier) @module)
(imported alias: (identifier) @module)
(type (identifier) @type .)
(type (identifier) @module ".")
(type (template_instance (identifier) @type))
(base_class (identifier) @type .)
(base_class (template_instance (identifier) @type))

; Member access is a property unless it is the callee of a call.
(property_expression (identifier) @property .)
(member_initializer . (identifier) @property ":")
(named_argument . (identifier) @property ":")

; Ordinary, qualified, UFCS, chained and explicitly instantiated calls.
; Anchor identifiers so arguments and template values are not callees.
(call_expression . (identifier) @function)
(call_expression . (type (identifier) @function .))
(call_expression . (template_instance . (identifier) @function))
(call_expression . (type (template_instance . (identifier) @function) .))
; This grammar also represents obj.method() as a qualified type call.
; Syntax alone cannot distinguish a module-qualified function from a method.
(call_expression . (type "." (identifier) @function.method .))
(call_expression . (type "."
  (template_instance . (identifier) @function.method) .))
(call_expression . (property_expression (identifier) @function.method .))
(call_expression . (property_expression
  (template_instance . (identifier) @function.method) .))

; Declarations and aggregate types.
(function_declaration (identifier) @function.definition)
(struct_declaration (identifier) @type)
(class_declaration (identifier) @type)
(interface_declaration (identifier) @type.interface)
(union_declaration (identifier) @type)
(enum_declaration (identifier) @type)
(template_declaration (identifier) @type)
(alias_initializer . (identifier) @type)
(alias_declaration (type) . (identifier) @type)
(alias_reassign (identifier) @type)
((enum_member (identifier) @constant .) @_enum_member
  (#not-match? @_enum_member "="))
(enum_member (identifier) @constant "=")
(anonymous_enum_member (type) . (identifier) @constant "=")
(manifest_declarator . (identifier) @constant)

; Local declarations must override naming heuristics, but never their values.
(declarator . (identifier) @variable)
(bitfield_declarator . (identifier) @property)
(auto_declaration variable: (identifier) @variable)
(aggregate_body (variable_declaration (declarator . (identifier) @property)))
(aggregate_body (auto_declaration variable: (identifier) @property))

; Parameter names, not identifiers in default expressions. The no-default
; case excludes '=' because anonymous parameters may have default values.
((parameter (type) . (identifier) @variable.parameter .) @_parameter
  (#not-match? @_parameter "="))
(parameter (type) . (identifier) @variable.parameter "=")
(parameter (type) . (identifier) @variable.parameter (ellipses))
(foreach_type (type)? . (identifier) @variable.parameter .)
(function_literal . (identifier) @variable.parameter "=>")
; Parenthesized lambdas/delegates have their parameter nodes inlined by
; this grammar. Bound names by the parameter separator, not the lambda body.
(function_literal (type) . (identifier) @variable.parameter ["," ")"])
(function_literal (type) . (identifier) @variable.parameter "=")
(function_literal ["(" ","]
  (type . (identifier) @variable.parameter .) . ["," ")"])
; Bare default expressions can be direct identifier children too. Restore
; their fallback classification instead of treating them as parameter names.
[(parameter "=" (identifier) @variable)
 (function_literal "=" (identifier) @variable)]
([(parameter "=" (identifier) @type)
  (function_literal "=" (identifier) @type)]
  (#match? @type "^[A-Z]"))
([(parameter "=" (identifier) @constant)
  (function_literal "=" (identifier) @constant)]
  (#match? @constant "^_*[A-Z][A-Z0-9_]*$"))
(out_contract_expression (identifier) @variable.parameter)
(out_statement (identifier) @variable.parameter)

; Template type/sequence, value and alias parameters are not all types.
(template_parameter . (identifier) @type)
(template_parameter (this) . (identifier) @type)
(template_parameter (type) . (identifier) @variable.parameter)
(template_parameter (alias) . (type)? . (identifier) @variable.parameter)

; Highlight only the attribute name, leaving its arguments normally colored.
(at_attribute . (identifier) @attribute)
(at_attribute . (template_instance . (identifier) @attribute))
(traits_expression (traits) . (identifier) @function.builtin)
(pragma_expression (pragma) . (identifier) @function.builtin)

[
    (abstract)
    (alias)
    (align)
    (asm)
    (assert)
    (auto)
    (cast)
    (class)
    (const)
    (debug)
    (delegate)
    (delete)
    (deprecated)
    (enum)
    (export)
    (extern)
    (final)
    (function)
    (immutable)
    (import)
    (in)
    (inout)
    (interface)
    (invariant)
    (is)
    (lazy)
    ; "macro" - obsolete
    (mixin)
    (module)
    (new)
    (nothrow)
    (out)
    (override)
    (package)
    (pragma)
    (private)
    (protected)
    (public)
    (pure)
    (ref)
    (scope)
    (shared)
    (static)
    (struct)
    (super)
    (synchronized)
    (template)
    (this)
    (throw)
    (typeid)
    (typeof)
    (union)
    (unittest)
    (version)
    (with)
    (gshared)
    (traits)
    (vector)
    (parameters_)
] @keyword

[
    (break)
    (case)
    (catch)
    (continue)
    (do)
    (default)
    (finally)
    (else)
    (for)
    (foreach)
    (foreach_reverse)
    (goto)
    (if)
    (switch)
    (try)
    (return)
    (while)
] @keyword.control

[
    (not_in)
    (not_is)
    "/="
    "/"
    ".."
    "..."
    "&"
    "&="
    "&&"
    "|"
    "|="
    "||"
    "-"
    "-="
    "--"
    "+"
    "+="
    "++"
    "<"
    "<="
    "<<"
    "<<="
    ">"
    ">="
    ">>="
    ">>>="
    ">>"
    ">>>"
    "!"
    "!="
    "?"
    "$"
    "="
    "=="
    "*"
    "*="
    "%"
    "%="
    "^"
    "^="
    "^^"
    "^^="
    "~"
    "~="
    "@"
    "=>"
] @operator

[
    ";"
    "."
    ":"
    ","
] @punctuation.delimiter

[
    "("
    ")"
    "["
    "]"
    "{"
    "}"
] @punctuation.bracket

(null) @constant.language

[(true) (false)] @boolean
(ellipses) @punctuation.special
(dollar) @variable.special
[(this) (super)] @variable.special

(special_keyword) @constant.language

(directive) @keyword.directive
(shebang) @keyword.directive

(comment) @comment
((comment) @comment.doc
  (#match? @comment.doc "^(///|/\\*\\*|/\\+\\+)"))

[
    (void)
    (bool)
    (byte)
    (ubyte)
    (char)
    (short)
    (ushort)
    (wchar)
    (dchar)
    (int)
    (uint)
    (long)
    (ulong)
    (real)
    (double)
    (float)
    (size_t)
    (ptrdiff_t)
    (string)
    (cstring)
    (dstring)
    (wstring)
    (noreturn)
] @type.builtin

[
    (cent)
    (ucent)
    (ireal)
    (idouble)
    (ifloat)
    (creal)
    (cdouble)
    (cfloat)
] @type.deprecated

(label (identifier) @label)
(goto_statement (goto) @keyword.control (identifier) @label)

; these are listed last, because they override keyword queries
[
    (lazy)
    (align)
    (extern)
    (static)
    (abstract)
    (final)
    (override)
    (synchronized)
    (auto)
    (scope)
    (gshared)
    (ref)
    (deprecated)
    (nothrow)
    (pure)
    (type_ctor)
] @keyword.storage
(parameter_attribute (return) @keyword.storage)
(parameter_attribute (in) @keyword.storage)
(parameter_attribute (out) @keyword.storage)
(at_attribute "@" @attribute)
(constructor (this) @function.definition)
(destructor (this) @function.definition)
(postblit (this) @function.definition)
(identity_expression (in) @operator)
(identity_expression (is) @operator)
((htmlentity) @string.special)
((escape_sequence) @string.escape)
(interpolated_escape) @string.escape
(interpolation_expression "$(" @punctuation.special ")" @punctuation.special)

; everything after __EOF_ is plain text
(end_file) @text
