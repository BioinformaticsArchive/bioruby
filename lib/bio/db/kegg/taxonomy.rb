#
# = bio/db/kegg/taxonomy.rb - KEGG taxonomy parser class
#
# Copyright::  Copyright (C) 2007 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
#  $Id: taxonomy.rb,v 1.1 2007/07/09 08:48:03 k Exp $
#

module Bio
class KEGG

# == Description
#
# Parse the KEGG 'taxonomy' file which describes taxonomic classification
# of organisms.
#
# == References
#
# The KEGG 'taxonomy' file is available at
#
# * ftp://ftp.genome.jp/pub/kegg/genes/taxonomy
#
class Taxonomy

  def initialize(filename, orgs = [])
    @tree = Hash.new
    @path = Array.new
    @leaves = Hash.new

    # �롼�ȥΡ��ɤ� Genes �Ȥ���
    @root = 'Genes'

    hier = Array.new
    level = 0
    label = nil

    File.open(filename).each do |line|
      next if line.strip.empty?

      # �������Υߡ����ع� - # �θĿ��ǳ��ؤ򥤥�ǥ�Ȥ������
      if line[/^#/]
	level = line[/^#+/].length
	label = line[/[A-z].*/]
	hier[level] = sanitize(label)

      # ��ʪ��ꥹ�ȹ� - ��ʪ�拾���ɤȥ��ȥ쥤��㤤��ޤȤ�����
      else
	tax, org, name, desc = line.chomp.split("\t")
        if orgs.nil? or orgs.empty? or orgs.include?(org)
          species, strain, = name.split('_')
          # (0) species ̾��ľ���ιԤΤ�Τ�Ʊ����硢���Υ��롼�פ��ɲ�
          #  Gamma/enterobacteria �ʤɳ�꤬��ޤ��Ǽ����¿�����롼�פ�
          #  Ʊ����̾�ʥ��ȥ쥤��㤤�ˤ��Ȥ˥��֥��롼�ײ�����Τ���Ū
          #   ex. E.coli, H.influenzae �ʤ�
          # �ȥ�å�������ʬ��
          #  �⤷ species ̾�������֥Ρ��ɡ�### �Ԥʤɡˤ�Ʊ���ʴ��СˤǤ����
          #  Tree �� Hash �ǻ��Ļ��ͤȥ���եꥯ�Ȥ���Τ���̾��ɬ��
          # (1) species ̾�������ΰۤʤ�����֥Ρ���̾��Ʊ�����
          #   �� �Ȥꤢ���� species ̾�� _sp ��Ĥ��ƥ���եꥯ�Ȥ��򤱤� (1-1)
          #      ���Ǥ� _sp ��Ȥ��Ƥ������ strain ̾��Ȥ� (1-2)
          #   ex. Bacteria/Proteobacteria/Beta/T.denitrificans/tbd ��
          #       Bacteria/Proteobacteria/Epsilon/T.denitrificans_ATCC33889/tdn
          #    -> Bacteria/Proteobacteria/Beta/T.denitrificans/tbd ��
          #       Bacteria/Proteobacteria/Epsilon/T.denitrificans_sp/tdn
          # (2) species ̾���嵭��֥Ρ���̾��Ʊ�����
          #   �� �Ȥꤢ���� species ̾�� _sp ��Ĥ��ƥ���եꥯ�Ȥ��򤱤�
          #   ex. Bacteria/Cyanobacgteria/Cyanobacteria_CYA/cya
          #       Bacteria/Cyanobacgteria/Cyanobacteria_CYB/cya
          #       Bacteria/Proteobacteria/Magnetococcus/Magnetococcus_MC1/mgm
          #    -> Bacteria/Cyanobacgteria/Cyanobacteria_sp/cya
          #       Bacteria/Cyanobacgteria/Cyanobacteria_sp/cya
          #       Bacteria/Proteobacteria/Magnetococcus/Magnetococcus_sp/mgm
          sp_group = "#{species}_sp"
          if @tree[species]
            if hier[level+1] == species
              # case (0)
            else
              # case (1-1)
              species = sp_group
              # case (1-2)
              if @tree[sp_group] and hier[level+1] != species
                species = name
              end
            end
          else
            if hier[level] == species
              # case (2)
              species = sp_group
            end
          end
          # hier �� [nil, Eukaryotes, Fungi, Ascomycetes, Saccharomycetes] ��
          # species �� org �� [S_cerevisiae, sce] ��ä�������
          hier[level+1] = species
          #hier[level+1] = sanitize(species)
          hier[level+2] = org
          ary = hier[1, level+2]
          warn ary.inspect if $DEBUG
          add_to_tree(ary)
          add_to_leaves(ary)
          add_to_path(ary)
        end
      end
    end
    return tree
  end

  attr_reader :tree
  attr_reader :path
  attr_reader :leaves
  attr_accessor :root

  def organisms(group)
    @leaves[group]
  end

  # root �Ρ��ɤβ��� [node, subnode, subsubnode, ..., leaf] �ʥѥ����ɲ�
  # ����֥Ρ��ɤ������Ǥ�ϥå�����ݻ�
  def add_to_tree(ary)
    parent = @root
    ary.each do |node|
      @tree[parent] ||= Hash.new
      @tree[parent][node] = nil
      parent = node
    end
  end

  # ����֥Ρ��ɤ��б�����꡼�դΥꥹ�Ȥ��ݻ�
  def add_to_leaves(ary)
    leaf = ary.last
    ary.each do |node|
      @leaves[node] ||= Array.new
      @leaves[node] << leaf
    end
  end

  # ����֥Ρ��ɤޤǤΥѥ����ݻ�
  def add_to_path(ary)
    @path << ary
  end

  # �ƥΡ��ɤ��鸫�ƻҥΡ��ɤ�¹�Ρ��ɤ򣱤Ĥ������äƤ��ʤ���硢
  # ¹�Ρ��ɤλҶ��ʤ�¹�ˤ򡢻ҥΡ��ɤλҡ�¹�ˤȤ���
  #
  # ex.
  #  Plants / Monocotyledons / grass family / osa --> Plants / Monocotyledons / osa
  #
  def compact(node = root)
    # �ҥΡ��ɤ�����
    if subnodes = @tree[node]
      # ���줾��λҥΡ��ɤˤĤ���
      subnodes.keys.each do |subnode|
        # ¹�Ρ��ɤ����
        if subsubnodes = @tree[subnode]
          # ¹�Ρ��ɤο��� 1 �Ĥξ��
          if subsubnodes.keys.size == 1
            # ¹�Ρ��ɤ�̾�������
            subsubnode = subsubnodes.keys.first
            # ¹�Ρ��ɤλҶ������
            if subsubsubnodes = @tree[subsubnode]
              # ¹�Ρ��ɤλҶ���ҥΡ��ɤλҶ��ˤ�������
              @tree[subnode] = subsubsubnodes
              # ¹�Ρ��ɤ���
              @tree[subnode].delete(subsubnode)
              warn "--- compact: #{subsubnode} is replaced by #{subsubsubnodes}" if $DEBUG
              # ������¹�Ρ��ɤǤ� compact ��ɬ�פ��⤷��ʤ����ᷫ���֤�
              retry
            end
          end
        end
        # �ҥΡ��ɤ�ƥΡ��ɤȤ��ƺƵ�
        compact(subnode)
      end
    end
  end

  # �꡼�եΡ��ɤ����Ĥξ�硢�ƥΡ��ɤ�꡼�եΡ��ɤˤ���������
  #
  # ex.
  #  Plants / Monocotyledons / osa --> Plants / osa
  #
  def reduce(node = root)
    # �ҥΡ��ɤ�����
    if subnodes = @tree[node]
      # ���줾��λҥΡ��ɤˤĤ���
      subnodes.keys.each do |subnode|
        # ¹�Ρ��ɤ����
        if subsubnodes = @tree[subnode]
          # ¹�Ρ��ɤο��� 1 �Ĥξ��
          if subsubnodes.keys.size == 1
            # ¹�Ρ��ɤ�̾�������
            subsubnode = subsubnodes.keys.first
            # ¹�Ρ��ɤ��꡼�դξ��
            unless @tree[subsubnode]
              # ¹�Ρ��ɤ�ҥΡ��ɤˤ�������
              @tree[node].update(subsubnodes)
              # �ҥΡ��ɤ���
              @tree[node].delete(subnode)
              warn "--- reduce: #{subnode} is replaced by #{subsubnode}" if $DEBUG
            end
          end
        end
        # �ҥΡ��ɤ�ƥΡ��ɤȤ��ƺƵ�
        reduce(subnode)
      end
    end
  end

  # Ϳ����줿�Ρ��ɤȡ��ҥΡ��ɤΥꥹ�ȡ�Hash�ˤ򤦤��Ȥꡢ
  # �ҥΡ��ɤˤĤ��ƥ��ƥ졼����󤹤�
  def dfs(parent, &block)
    if children = @tree[parent]
      yield parent, children
      children.keys.each do |child|
        dfs(child, &block)
      end
    end
  end

  # ���ߤγ��ؤο����⥤�ƥ졼�������Ϥ�
  def dfs_with_level(parent, &block)
    @level ||= 0
    if children = @tree[parent]
      yield parent, children, @level
      @level += 1
      children.keys.each do |child|
        dfs_with_level(child, &block)
      end
      @level -= 1
    end
  end

  # �ĥ꡼��¤�򥢥����������Ȥ�ɽ������
  def to_s
    result = "#{@root}\n"
    @tree[@root].keys.each do |node|
      result += subtree(node, "  ")
    end
    return result
  end

  private

  # �嵭 to_s �Ѥβ������᥽�å�
  def subtree(node, indent)
    result = "#{indent}+- #{node}\n"
    indent += "  "
    @tree[node].keys.each do |child|
      if @tree[child]
        result += subtree(child, indent)
      else
        result += "#{indent}+- #{child}\n"
      end
    end
    return result
  end

  def sanitize(str)
    str.gsub(/[^A-z0-9]/, '_')
  end

end # Taxonomy

end # KEGG
end # Bio



if __FILE__ == $0

  # Usage:
  # % wget ftp://ftp.genome.jp/pub/kegg/genes/taxonomy
  # % ruby taxonomy.rb taxonomy | less -S

  taxonomy = ARGV.shift
  org_list = ARGV.shift || nil

  if org_list
    orgs = File.readlines(org_list).map{|x| x.strip}
  else
    orgs = nil
  end

  tree = Bio::KEGG::Taxonomy.new(taxonomy, orgs)

  puts ">>> tree - original"
  puts tree

  puts ">>> tree - after compact"
  tree.compact
  puts tree

  puts ">>> tree - after reduce"
  tree.reduce
  puts tree

  puts ">>> path - sorted"
  tree.path.sort.each do |path|
    puts path.join("/")
  end

  puts ">>> group : orgs"
  tree.dfs(tree.root) do |parent, children|
    if orgs = tree.organisms(parent)
      puts "#{parent.ljust(30)} (#{orgs.size})\t#{orgs.join(', ')}"
    end
  end

  puts ">>> group : subgroups"
  tree.dfs_with_level(tree.root) do |parent, children, level|
    subgroups = children.keys.sort
    indent = " " * level
    label  = "#{indent} #{level} #{parent}"
    puts "#{label.ljust(35)}\t#{subgroups.join(', ')}"
  end

end
