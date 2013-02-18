



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
  def cons (right)
    var = @@conshash.fetch([false,self,right],nil)
    if var
      var
    else
      @@conshash[[false,self,right]] = GoTree.new(false,self,right);
    end
  end

  def snoc (right)
    var = @@conshash.fetch([true,self,right],nil)
    if var
      var
    else
      @@conshash[[true,self,right]] = GoTree.new(true,self,right);
    end
  end

  ## predicate
  def atom? ()
    @pebble
  end

  def null? ()
    !@pebble
  end

  ## print
  def to_s ()
    if self.equal?(ZERO)
      "0"
    elsif atom?
      "[#@left.#@right]"
    else
      "(#@left.#@right)"
    end
  end
end

ZERO = GoTree.new(0,nil,nil)
class GoTree
  @@conshash[[false,ZERO,ZERO]] = ZERO
end

ONE = ZERO.snoc(ZERO)


### literal
def encode_char (ch)
  a = ZERO
  code = ch.bytes.to_a[0]
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
  rstr = str.reverse
  for i in 0...str.length
    a = encode_char(rstr[i]).snoc(a)
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


### parser
class Parser
  def initialize(str)
    @str = str
    @idx = 0
  end

  def readc()
    @idx += 1
    @str[@idx-1]
  end
  
  def parse()
    case readc()
    when "(" then
      left = parse
      readc()
      right = parse
      readc()
      left.cons(right)
    when "[" then
      left = parse
      readc()
      right = parse
      readc()
      left.snoc(right)
    when "0" then
      ZERO
    end
  end
end


### evaluator
## lambda expression
LAMBDA = encode_string("lambda")

def lambda? (x)
  x.car.equal?(LAMBDA)
end


def apply (fn,args)
  if lambda?(fn)
    apply_lambda(fn,args)
  elsif var = $symbol_primitive_function_map.fetch(fn,nil)
    var.call(args)
  elsif var = $symbol_function_map.fetch(fn,nil)
    apply(var,args)
  else
    puts "Error: definition for #{fn} was not found."
  end
end

def apply_lambda (fn,args)
  evals(subst_lambda(fn.cdr.car,fn.cdr.cdr.car,args))
end

def subst_lambda (param,body,args)
  if param.equal?(ZERO)
    body
  elsif param.atom?
    destruct_tree(param.car,args)
  elsif body.atom?
    subst_lambda(param.car,body.car,args).snoc(subst_lambda(param.cdr,body.cdr,args))
  else
    subst_lambda(param.car,body.car,args).cons(subst_lambda(param.cdr,body.cdr,args))
  end
end

def destruct_tree (location,args)
  if location.equal?(ONE)
    args
  elsif location.car.equal?(ZERO)
    destruct_tree(location.cdr,args.cdr)
  else
    destruct_tree(location.car,args.car)
  end
end

## eval
def evals (x)
  if x.atom?
    apply(x.car,x.cdr)
  else
    apply(x.car,evlis(x.cdr))
  end
end

def evlis (x)
  if x.equal?(ZERO)
    ZERO
  elsif x.atom?
    x.car.cons(evlis(x.cdr))
  else
    evals(x.car).cons(evlis(x.cdr))
  end
end

### build-in functions
## primitive functions
$symbol_primitive_function_map = {}

def define_primitive (name,&body)
  if name.is_a?(String)
    $symbol_primitive_function_map[encode_string(name)] = body
  else
    $symbol_primitive_function_map[name] = body
  end
end

define_primitive ZERO do |x|
  ZERO
end

define_primitive ONE do |x|
  x.car
end

define_primitive "eq" do |x|
  if x.car.equal?(x.cdr.car)
    ONE
  else
    ZERO
  end
end

define_primitive "atom" do |x|
  if x.car.atom?
    ONE
  else
    ZERO
  end
end

define_primitive "null" do |x|
  if x.car.null?
    ONE
  else
    ZERO
  end
end

define_primitive "if" do |x|
  pred = x.car
  thenbody = x.cdr.car
  elsebody = x.cdr.cdr.car
  if pred.equal?(ONE)
    evals(thenbody)
  else
    evals(elsebody)
  end
end

## built-in-functions
$symbol_function_map = {}

def define_function(name,tree)
  if name.is_a?(String)
    $symbol_function_map[encode_string(name)] = Parser.new(tree).parse
  elsif name.is_a?(GoTree)
    $symbol_function_map[name] = Parser.new(tree).parse
  else
    puts "error: name is invalid."
  end
end

define_function("car","([[[0.0].[[0.0].[0.[[0.0].[[0.0].[0.[0.0]]]]]]].[[[0.0].[[0.0].[0.[0.[0.[0.[[0.0].0]]]]]]].[[[0.0].[[0.0].[0.[[0.0].[[0.0].[0.[[0.0].0]]]]]]].[[[0.0].[[0.0].[0.[0.[0.[[0.0].[0.0]]]]]]].[[[0.0].[[0.0].[0.[0.[[0.0].[0.[0.0]]]]]]].[[[0.0].[[0.0].[0.[0.[0.[0.[[0.0].0]]]]]]].0]]]]]].((0.([(([0.0].0).0).0].0)).([[0.0].[0.0]].0)))")

define_function("cdr","([[[0.0].[[0.0].[0.[[0.0].[[0.0].[0.[0.0]]]]]]].[[[0.0].[[0.0].[0.[0.[0.[0.[[0.0].0]]]]]]].[[[0.0].[[0.0].[0.[[0.0].[[0.0].[0.[[0.0].0]]]]]]].[[[0.0].[[0.0].[0.[0.[0.[[0.0].[0.0]]]]]]].[[[0.0].[[0.0].[0.[0.[[0.0].[0.[0.0]]]]]]].[[[0.0].[[0.0].[0.[0.[0.[0.[[0.0].0]]]]]]].0]]]]]].((0.([((0.[0.0]).0).0].0)).([[0.0].[0.0]].0)))")

define_function("cons","([[[0.0].[[0.0].[0.[[0.0].[[0.0].[0.[0.0]]]]]]].[[[0.0].[[0.0].[0.[0.[0.[0.[[0.0].0]]]]]]].[[[0.0].[[0.0].[0.[[0.0].[[0.0].[0.[[0.0].0]]]]]]].[[[0.0].[[0.0].[0.[0.[0.[[0.0].[0.0]]]]]]].[[[0.0].[[0.0].[0.[0.[[0.0].[0.[0.0]]]]]]].[[[0.0].[[0.0].[0.[0.[0.[0.[[0.0].0]]]]]]].0]]]]]].((0.([([0.0].0).0].[(0.([0.0].0)).0])).([[0.0].(0.0)].0)))")

define_function("snoc","([[[0.0].[[0.0].[0.[[0.0].[[0.0].[0.[0.0]]]]]]].[[[0.0].[[0.0].[0.[0.[0.[0.[[0.0].0]]]]]]].[[[0.0].[[0.0].[0.[[0.0].[[0.0].[0.[[0.0].0]]]]]]].[[[0.0].[[0.0].[0.[0.[0.[[0.0].[0.0]]]]]]].[[[0.0].[[0.0].[0.[0.[[0.0].[0.[0.0]]]]]]].[[[0.0].[[0.0].[0.[0.[0.[0.[[0.0].0]]]]]]].0]]]]]].((0.([([0.0].0).0].[(0.([0.0].0)).0])).([[0.0].[0.0]].0)))")


### REPL
i = 0
print "0> "
while l = gets
  puts evals(Parser.new(l).parse)
  i += 1
  print "#{i}> "
end
