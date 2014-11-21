var build,
    cache,
    definition,
    path = require('path'),
    _ = require('underscore'),
    pegjs = require('pegjs');

definition = "message\n  = segments\nsegments\n  = head:msh tail:(newline segment:segment { return segment; })* {\n    tail.unshift(head);\n    return tail;\n  }\nmsh\n  = \"MSH\" fs:field_separator cs:component_separator fr:field_repeat_delimiter ec:escape_character ss:subcomponent_separator tail:(field_separator field:field { return field; })* {\n    tail.unshift([['MSH']], [[ cs + fr + ec + ss ]]);\n    return tail;\n  }\nsegment\n  = head:field tail:(field_separator field:field { return field; })* {\n    tail.unshift(head);\n    return tail;\n  }\nfield\n  = head:component tail:(component_separator component:component { return component;} )* {\n    tail.unshift(head);\n    return tail;\n  }\ncomponent\n  = head:subcomponent tail:(subcomponent_separator subcomponent:subcomponent { return subcomponent; })* {\n    tail.unshift(head);\n    return tail;\n  }\nsubcomponent\n  = content:(!(subcomponent_separator / component_separator / field_separator / newline) char:char { return char; } )* {\n    return content.join('');\n  }\nchar =\n  .\nescape_character\n  = \"\\<%=escape%>\"\nfield_repeat_delimiter\n  = \"<%=repeat%>\"\nfield_separator\n  = \"<%=fields%>\"\ncomponent_separator\n  = \"<%=components%>\"\nnewline\n  = [\\r\\n]+\nsubcomponent_separator\n  = \"<%=subcomponents%>\"\n";

build = function(options) {
    return pegjs.buildParser(_.template(definition, options));
};

cache = {};

module.exports = {
    parse: function(s) {
        var components, control_characters, escape, fields, message, repeat, subcomponents, _ref;

        control_characters = s.substring(3, 8);
        _ref = control_characters.split(''), fields = _ref[0], components = _ref[1], repeat = _ref[2], escape = _ref[3], subcomponents = _ref[4];
        if (!cache[control_characters]) {
            cache[control_characters] = build({
                fields: fields,
                components: components,
                repeat: repeat,
                escape: escape,
                subcomponents: subcomponents
            });
        }
        message = cache[control_characters].parse(s);
        return {
            control_characters: {
                fields: fields,
                components: components,
                repeat: repeat,
                escape: escape,
                subcomponents: subcomponents
            },
            message: message
        };
    }
};
