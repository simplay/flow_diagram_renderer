require "prawn"
require 'pry'

# units are in points pt (1 pt = 1 / 72 inch)
class Point

  attr_reader :x, :y

  def initialize(x=0, y=0)
    @x = x
    @y = y
  end

  def add(other)
    @x += other.x
    @y += other.y
    self
  end

  def to_a
    [x, y]
  end
end

class Arrow
  def initialize(from, to)
    @from = from
    @to = to
  end

  def draw_onto(pdf)

    dx = Circle::RADIUS

    start = Point.new(@from.x, @from.y)

    case @to.direction
      when :left
        pdf.move_to(start.x - dx, start.y)
        pdf.line_to(@to.x + dx, @to.y)
      when :right
        pdf.move_to(start.x + dx, start.y)
        pdf.line_to(@to.x - dx, @to.y)
      when :top
        pdf.move_to(start.x, start.y + dx)
        pdf.line_to(@to.x, @to.y - dx)
      when :bottom
        pdf.move_to(start.x, start.y - dx)
        pdf.line_to(@to.x, @to.y + dx)
    end

  end
end

class Circle
  RADIUS = 50
  OFFSET = 200

  attr_accessor :direction
  attr_reader :center

  # @param center [Point] center
  def initialize(center=Point.new, text = '')
    @children = []
    @center = center
    @text = text
  end

  def x
    center.x
  end

  def y
    center.y
  end

  def add(node, direction = :none)
    case direction
      when :left
        node.center.add(Point.new(-OFFSET, 0))
      when :right
        node.center.add(Point.new(OFFSET, 0))
      when :top
        node.center.add(Point.new(0, OFFSET))
      when :bottom
        node.center.add(Point.new(0, -OFFSET))
    end
    node.direction = direction
    @children << node
  end

  def draw_onto(pdf)
    pdf.stroke_circle @center.to_a, RADIUS
    pdf.draw_text(@text, :size => 16, :at => [x-RADIUS/2, y])

    @children.each do |child|
      #pdf.move_to(x, y)
      Arrow.new(self, child).draw_onto(pdf)
      child.draw_onto(pdf)
    end
  end
end

pdf = Prawn::Document.new
base = 50
root = Circle.new(Point.new(base+200, base+400), "base")

c = Circle.new(Point.new(root.x, root.y), "left")
root.add(c, :left)
c = Circle.new(Point.new(root.x, root.y), "right")
root.add(c, :right)
c = Circle.new(Point.new(root.x, root.y), "top")
root.add(c, :top)
c = Circle.new(Point.new(root.x, root.y), "bottom")
root.add(c, :bottom)


root.draw_onto(pdf)
pdf.render_file('flow_diagram.pdf')
