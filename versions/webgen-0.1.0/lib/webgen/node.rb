#
#--
#
# $Id$
#
# webgen: a template based web page generator
# Copyright (C) 2004 Thomas Leitner
#
# This program is free software; you can redistribute it and/or modify it under the terms of the GNU
# General Public License as published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program; if not,
# write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
#++
#

require 'util/composite'

class Node

  include Composite

  attr_reader   :parent
  attr_accessor :metainfo

  def initialize( parent )
    @parent = parent
    @metainfo = Hash.new
  end


  def []( name )
    @metainfo[name]
  end


  def []=( name, value )
    @metainfo[name] = value
  end


  def recursive_value( name )
    if @parent.nil?
      @metainfo[name].dup
    else
      @parent.recursive_value( name ) + @metainfo[name]
    end
  end


  # Returns the relative path from the srcNode to the destNode. The srcNode
  # is normally a page file node, but the method should work for other nodes
  # too. The destNode can be any non virtual node.
  def get_relpath_to_node( destNode )
    path = @parent.recursive_value( 'dest' )[UPS::Registry['Configuration'].outDirectory.length+1..-1]
    path = path.gsub(/.*?(#{File::SEPARATOR})/, "..#{File::SEPARATOR}")
    path += destNode.parent.recursive_value( 'dest' )[UPS::Registry['Configuration'].outDirectory.length+1..-1] unless destNode.parent.nil?
    path
  end


  # Returns the node identified by the given string relative to the current node.
  def get_node_for_string( destString, fieldname = 'src' )
    if /^#{File::SEPARATOR}/ =~ destString
      node = Node.root(self)
      destString = destString[1..-1]
    elsif self.kind_of? FileHandlers::DirHandler::DirNode
      node = self
    else
      node = @parent
    end

    destString.split(File::SEPARATOR).each do |element|
      node = node.parent while node['virtual']
      case element
      when '..'
        node = node.parent
      else
        node = node.find do |child| /#{element}#{File::SEPARATOR}?/ =~ child[fieldname] end
      end
      if node.nil?
        self.logger.error { "Could not get destination node for <#{metainfo['src']}> with '#{destString}', searching field #{fieldname}" }
        return
      end
    end

    return node
  end


  def Node.root( node )
    node = node.parent until node.parent.nil?
    node
  end

end