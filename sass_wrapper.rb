require 'sass'
require 'sass/css'
require 'sass/tree/node'

module SassWraper


    # TODO this class has static variables and keeps changes of states on the class-level
    # it will prevent to reuse it in different places of code at once
    class MyVisitor < Sass::Tree::Visitors::Base


        def self.convert(tree)
            @@root = {name: 'root', children: []}
            @@curr = @@root
            @@stack = []
            visit(tree)
            @@root
        end

        def visit_rule(rule)
            puts 'test'
            begin
                rule_name = rule.parsed_rules.members[0]
            rescue
                rule_name = rule.rule.join(' ')
            end

            @@stack.push(@@curr)
            
            node_data = {type: 'rule', rule: rule_name, children: [], line: rule.line}
            @@curr[:children].push(node_data)
            @@curr = node_data

            visit_children(rule)

            @@curr = @@stack.pop
        end

        def visit_prop(prop)
            @@curr[:children].push({type: 'prop', name: prop.name[0], 
                                   parent: @@curr[:line],
                                   value: prop.value.to_sass, line: prop.line})
        end
    end



    def SassWraper.parse(filename)
        engine = Sass::Engine.for_file(filename, {})
        tree = engine.to_tree
    end

    def SassWraper.generate(tree)
        tree.to_sass
    end

    # TODO we assume that order of properties/mixins/subrules will be the same as in frontend...
    # uhm... we can't assume that. It should be more independent. We need better form of addressing/referencing nodes
    # in tree...
    def SassWraper.modify_attribute!(tree, node_address, attr, val)
        def traverse(node)
            3
        end
        node = tree
        parent = nil
        node_address.each { |index|
            parent = node
            node = node.children[index]
        }
        if attr=='rule'
           node.parsed_rules.members[0] = val
           # parent.children[node_address.last] = node.deep_copy # Sass::Tree::RuleNode.new(['ssz'])
        else
          node.send(attr)[0] = val
        end
    end

    def SassWraper.load(filename)
        tree = parse(filename)
        MyVisitor.convert(tree)
    end
end
