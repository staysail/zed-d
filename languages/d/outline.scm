(function_declaration (type)? @context (identifier) @name (template_parameters)? @context (parameters) @context (function_body)) @item
(class_declaration (identifier) @name (template_parameters)? @context (aggregate_body)) @item
(interface_declaration (identifier) @name (template_parameters)? @context (aggregate_body)) @item
(struct_declaration (identifier) @name (template_parameters)? @context (aggregate_body)) @item
(constructor (this) @name (template_parameters)? @context (parameters) @context (function_body)) @item
(constructor (shared)? @context (static) @context (this) @name "(" @context ")" @context (function_body)) @item
(postblit (this) @name "(" @context (this) @context ")" @context (function_body)) @item
(destructor "~" @context (this) @name (function_body)) @item
(unittest_declaration (unittest) @context (block_statement)) @item
