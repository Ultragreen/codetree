#require "codetree/version"
require 'rubygems'
require 'ruby_parser'
require 'pp'


module Codetree


  class Operator
    attr_reader :type
    attr_reader :ancestors
    attr_accessor :scope
    attr_reader :line
    attr_reader :name

    def initialize(type: :defn, ancestors: [], scope: :none, name: "", line: 0 )
      @type = type
      @ancestors = ancestors
      @scope = scope
      @name = name
      @line = line
    end

    # @!group Virtual Accessors

    def ancestor
      return @ancestors.last
    end

    # @!endgroup
    


    def render
      return name.to_s if self.ancestors == []
      case type
      when :defn then return "##{name.to_s}"
      when :defs then return ".#{name.to_s}"
      when :class then return "::#{name.to_s}"
      when :module then return "::#{name.to_s}"
      end
    end

    # @!endgroup

  end


  class ParseTree
    attr_reader :operators    
    attr_reader :ast
    attr_reader :lines

    def initialize(files)
      @lines = Array::new
      files.each do |file|
        require "./#{file}"
        @lines << File::readlines(file)        
      end

      @lines.flatten!
      @lines = @lines.collect(&:strip!)
      @lines.delete_if {|line| line =~ /^\s*#/}
      @code = @lines.join("\n")
      @ast = RubyParser.new.process @code, "code"
      @operators = {} # positions of interest
      @operators_index = Hash::new
      @curr_position = []
      map_operators!
      generate_tree!
    end
    
    
    
    def format_operator(name, detail: :full)
      res = ""
      scope = { 
        :private => {   :full => "Private ",   :medium => '-', :light => ''},
        :public => {    :full => "Public ",    :medium => "+", :light => ''}, 
        :protected => { :full => "Protected ", :medium => "#", :light => ''},  
        :none => {      :full => "",           :medium => " ",  :light => ''} }
      type = { 
        :defn => {    :full => "Instance method ", :medium => '(m):', :light => ''},
        :defs => {    :full => "Class method ",    :medium => "(m) ",  :light => ''}, 
        :class => {   :full => "Class ",           :medium => "(C) ",  :light => ''},  
        :module => {  :full => "Module ",          :medium => "(M) ",  :light => ''} }
      if @operators.include?(name) then
        operator = @operators[name]
        operator.ancestors.each do |ancestor|
          res += @operators[ancestor].render
        end
        res = scope[operator.scope][detail] + type[operator.type][detail] + res +  operator.render
      end
      return res
    end
    
    
    def print_tree(detail: :medium, flat: false, quiet: false)
      print_subtree(@root,0, detail: detail, flat: flat, quiet: quiet )
    end
    
    
    private

    def map_operators!
      process_ast_level @ast
      define_scopes!
    end    

    def generate_tree!
      @root = {:name => '', :ancestor => nil}
      @tree = {}
      @operators.values.each do |operator|
        ancestor = operator.ancestor 
        if ancestor == nil || !@operators.has_key?(ancestor)
          (@tree[@root] ||= []) << operator
        else
          (@tree[@operators[ancestor]] ||= []) << operator
        end
      end
    end
    
    
    def register_operator(nodetype, name, linenr, ancestors)
      @operators[name] =  Codetree::Operator::new(type: nodetype, name: name, line: linenr, ancestors: ancestors )
      @operators_index[@curr_position.to_s] = [nodetype, name]
    end

    def define_scopes!
      @operators.each do |name,item|
        unless item.ancestor.nil? then
          klass = eval "#{format_operator item.ancestor, detail: :light}"
          if item.type == :defn then
            item.scope = :private if klass.private_method_defined? name
            item.scope = :protected if klass.protected_method_defined? name
            item.scope = :public if klass.public_method_defined? name
           elsif item.type == :defs and @operators[item.ancestor].type == :class then
             item.scope = :private if klass.private_method_defined? name
             item.scope = :protected if klass.protected_method_defined? name
             item.scope = :public if klass.public_method_defined? name
          end
        end
      end

    end



    def process_ast_level sub_astree
      return if sub_astree.empty?
      case sub_astree[0]
      when :module, :class, :defn, :private
        register_operator sub_astree[0], sub_astree[1], sub_astree.line, find_where_nested(@curr_position.clone)
      when :defs
        register_operator sub_astree[0], sub_astree[2], sub_astree.line, find_where_nested(@curr_position.clone)
      end
      sub_astree.each_with_index do |sae, i|
        @curr_position.push i
        process_ast_level(sae) if sae.is_a?(Sexp)
        ex_i = @curr_position.pop
      end
    end



    def print_subtree(item, level, detail: :full, flat: false, quiet: false)
      items = @tree[item]
      unless items == nil
        indent = (flat)? '': level > 0 ? sprintf("%#{level * 2}s", " ") : "" 
        node = (quiet)? "":"* "
        items.each do |operator|
          if detail == :none then
            puts "#{indent}#{node}#{operator.name}"
          else
            puts "#{indent}#{node}#{format_operator operator.name, detail: detail}" 
          end
          print_subtree(operator, level + 1, detail: detail, flat: flat, quiet: quiet)
        end
      end
    end
    
      
    NESTING_NODES = [:module, :class ] unless const_defined? :NESTING_NODES
    def find_where_nested(position)
      result = []
      for ep in 0..position.size-2 do
        chunk = position[0..ep]
        el = @operators_index[chunk.to_s]
        if el
          eltype, elname = el
          result << elname if NESTING_NODES.include?(eltype)
        end
      end
      result
    end
    



  end




end

