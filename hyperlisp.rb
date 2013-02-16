



### internal expression

class GoTree
  @@conshash = {}

  def initialize(pebble,left,right)
    @pebble = pebble
    @left  = left
    @right = right
  end

  def eql?(obj)
    self.equal?(obj)
  end

  ## accessor
  def car
    @left || ZERO
  end

  def cdr
    @right || ZERO
  end

  ## generator
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

  ## predicate
  def atom?()
    @pebble
  end

  def null?()
    !@pebble
  end
end

ZERO = GoTree.new(0,nil,nil)
class GoTree
  @@conshash[[false,ZERO,ZERO]] = ZERO
end



### evaluator

def apply(fn,args)
  #FIXME
end

def eval(x)
  if x.atom?
    apply(x.car,x.cdr)
  else
    apply(x.car,evlis(x.cdr))
  end
end

def evalis(x)
  if x.equal?(ZERO)
    ZERO
  elsif x.atom?
    x.car.cons(evlis(x.cdr))
  else
    eval(x.car).cons(evlis(x.cdr))
  end
end

