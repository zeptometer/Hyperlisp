



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

ONE  ZERO.snoc(ZERO)


### literal
def encode_char (ch)
  a = ZERO
  code = ch.bytes.to_z[0]
  for i in 0..6
    if (code >> i & 1) == 0
      a = ZERO.snoc(a)
    else
      a = ONE.snoc(a)
    end
  end
  a
end

def encode_string (str)
  a = ZERO
  for i in str.length
    a = makechar(str[i]).snoc(a)
  end
  a
end

def decode_char (x)
  a = x
  ch = 0
  while a != ZERO
    ch <<= 1
    ch += 1 if a.car == ONE
    a = a.cdr
  end
  ch.chr
end

def decode_string (x)
  a = x
  str = ""
  while a != ZERO
    str = str + decode_char(a.car)
    a = a.cdr
  end
  str
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

