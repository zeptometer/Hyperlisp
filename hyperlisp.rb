



# internal expression

class GoTree
  attr_accessor :pebble
  @@conshash = {}

  def initialize(pebble,left,right)
    @pebble = pebble
    @left  = left
    @right = right
  end

  def eql?(obj)
    self.equal?(obj)
  end

  def car
    @left || ZERO
  end

  def cdr
    @right || ZERO
  end

  def cons(right)
    var = @@conshash.fetch([false,self,right],nil)
    if var
      var
    else
      @@conshash[[false,self.right]] = GoTree.new(false,self,right);
    end
  end

  def snoc(right)
    var = @@conshash.fetch([true,self,right],nil)
    if var
      var
    else
      @@conshash[[true,self,right]] = GoTree.new(true,self,right);
    end
  end
end

ZERO = GoTree.new(0,nil,nil)
class GoTree
  @@conshash[[false,ZERO,ZERO]] = ZERO
end





