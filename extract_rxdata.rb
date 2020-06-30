# 99% of the code is from: http://www.rpg-maker.fr/dl/monos/aide/xp/index.html

# The easy part
module RPG
  class Map
    def initialize(width, height)
      @tileset_id = 1
      @width = width
      @height = height
      @autoplay_bgm = false
      @bgm = RPG::AudioFile.new
      @autoplay_bgs = false
      @bgs = RPG::AudioFile.new("", 80)
      @encounter_list = []
      @encounter_step = 30
      @data = Table.new(width, height, 3)
      @events = {}
    end
    attr_accessor :tileset_id
    attr_accessor :width
    attr_accessor :height
    attr_accessor :autoplay_bgm
    attr_accessor :bgm
    attr_accessor :autoplay_bgs
    attr_accessor :bgs
    attr_accessor :encounter_list
    attr_accessor :encounter_step
    attr_accessor :data
    attr_accessor :events
  end
  
  class AudioFile
    def initialize(name = "", volume = 100, pitch = 100)
      @name = name
      @volume = volume
      @pitch = pitch
    end
    attr_accessor :name
    attr_accessor :volume
    attr_accessor :pitch
  end
  
  class Event
    def initialize(x, y)
      @id = 0
      @name = ""
      @x = x
      @y = y
      @pages = [RPG::Event::Page.new]
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :x
    attr_accessor :y
    attr_accessor :pages
  end
  
  class Event
    class Page
      def initialize
        @condition = RPG::Event::Page::Condition.new
        @graphic = RPG::Event::Page::Graphic.new
        @move_type = 0
        @move_speed = 3
        @move_frequency = 3
        @move_route = RPG::MoveRoute.new
        @walk_anime = true
        @step_anime = false
        @direction_fix = false
        @through = false
        @always_on_top = false
        @trigger = 0
        @list = [RPG::EventCommand.new]
      end
      attr_accessor :condition
      attr_accessor :graphic
      attr_accessor :move_type
      attr_accessor :move_speed
      attr_accessor :move_frequency
      attr_accessor :move_route
      attr_accessor :walk_anime
      attr_accessor :step_anime
      attr_accessor :direction_fix
      attr_accessor :through
      attr_accessor :always_on_top
      attr_accessor :trigger
      attr_accessor :list
    end
  end
  
  class EventCommand
    def initialize(code = 0, indent = 0, parameters = [])
      @code = code
      @indent = indent
      @parameters = parameters
    end
    attr_accessor :code
    attr_accessor :indent
    attr_accessor :parameters
  end
 
  class Event
    class Page
      class Condition
        def initialize
          @switch1_valid = false
          @switch2_valid = false
          @variable_valid = false
          @self_switch_valid = false
          @switch1_id = 1
          @switch2_id = 1
          @variable_id = 1
          @variable_value = 0
          @self_switch_ch = "A"
        end
        attr_accessor :switch1_valid
        attr_accessor :switch2_valid
        attr_accessor :variable_valid
        attr_accessor :self_switch_valid
        attr_accessor :switch1_id
        attr_accessor :switch2_id
        attr_accessor :variable_id
        attr_accessor :variable_value
        attr_accessor :self_switch_ch
      end
    end
  end

  class MoveRoute
    def initialize
      @repeat = true
      @skippable = false
      @list = [RPG::MoveCommand.new]
    end
    attr_accessor :repeat
    attr_accessor :skippable
    attr_accessor :list
  end
  
  class MoveCommand
    def initialize(code = 0, parameters = [])
      @code = code
      @parameters = parameters
    end
    attr_accessor :code
    attr_accessor :parameters
  end
  
  class Event
    class Page
      class Graphic
        def initialize
          @tile_id = 0
          @character_name = ""
          @character_hue = 0
          @direction = 2
          @pattern = 0
          @opacity = 255
          @blend_type = 0
        end
        attr_accessor :tile_id
        attr_accessor :character_name
        attr_accessor :character_hue
        attr_accessor :direction
        attr_accessor :pattern
        attr_accessor :opacity
        attr_accessor :blend_type
      end
    end
  end
end

class Color
  def initialize(r, g, b, a)
    @r = r
	@g = g
	@b = b
	@a = a
  end
  attr_accessor :r
  attr_accessor :g
  attr_accessor :b
  attr_accessor :a
  
  def self._load args
    # new(*args.split(':'))
	# print(args)
	values = args.unpack('d4')
	new(*values)
  end
end

class Table
  def initialize(xsize, ysize, zsize, data)
    @xsize = xsize
	@ysize = ysize
	@zsize = zsize

	# Create an empty array
	res = []
	x = 0
	y = 0
	z = 0
	current1 = []
	current2 = []
	loop do
		if z >= zsize then
			current2.append(current1)
			current1 = []
			z = 0
			y += 1
		end
		if y >= ysize then
			res.append(current2)
			current2 = []
			y = 0
			x += 1
		end
		if x >= xsize then
			break
		end
		current1.append(0)
		z += 1
	end
	
	# Fill it in
	x = 0
	y = 0
	z = 0
	loop do
		if x >= xsize then
			x = 0
			y += 1
		end
		if y >= ysize then
			y = 0
			z += 1
		end
		if z >= zsize then
			break
		end
		
		datapos = (z * xsize * ysize + y * xsize + x)*2
		res[x][y][z] = data[datapos..(datapos+2)].unpack("S")[0]
		x += 1
	end 
	
	@array = res
  end
  
  def self._load data
    # new(*args.split(':'))
	# print(args)
	# values = args.unpack('d4')
	# new(*values)
	# args[0..].unpack("L")
	xsize = data[ 4..].unpack("L")[0]
	ysize = data[ 8..].unpack("L")[0]
	zsize = data[12..].unpack("L")[0]
	size  = data[16..].unpack("L")[0]
	if (xsize * ysize * zsize) != size then
		raise RGSSError.new("Marshal: Table: bad file format")
	end
	# print(xsize, "\n", ysize, "\n", zsize, "\n", size, "\n")
	new(xsize, ysize, zsize, data[20..])
  end
  
  attr_accessor :xsize
  attr_accessor :ysize
  attr_accessor :zsize
  attr_accessor :array
end

class RGSSError < StandardError
end

f = File.open(ARGV[0], "rb")
obj = Marshal.load(f)
# print(obj, "\n")

# The hard part
def serialize_obj(obj)
  attrn = obj.instance_variables.length
  print(attrn.to_s, " ")
  obj.instance_variables.each do |attr_name|
    value = obj.send(attr_name.to_s[1..])
    print(attr_name.to_s, " ")
	serialize(value)
  end
end

def serialize(value)
  if value.class == Integer then
    print(value.class.to_s, " ", value.to_s, " ")
	# STDERR.puts(value.class.to_s, " ", value.to_s, " ")
  else
    if value.class == String then
      print(value.class.to_s, " ", value.length.to_s, " ", value.to_s, " ")
    else
      if value.class == Array then
		i = 0
		print(value.class.to_s, " ")
		print(value.length.to_s, " ")
		loop do
		  if i >= value.length
		    break
		  end
		  serialize(value[i])
		  # print(" ")
		  i += 1
		end
      else
	    if value.class == Hash then
		  print(value.class.to_s, " ")
		  print(value.length.to_s, " ")
		  value.each do | k, v |
            serialize(k)
			print(" ")
			serialize(v)
          end
		  print(" ")
		else
	      print(value.class.to_s, " ")
		  serialize_obj(value)
		  print(" ")
		end
      end
    end
  end
end

serialize(obj)