
require 'flor'
require 'flor/unit'


module Flor::Tools
  class Repl

    def initialize(env)

      unit = Flor::Unit.new("envs/#{env}/etc/conf.json")

      #pp unit.conf
      unit.conf[:unit] = 'repl'

      #unit.hooker.add('journal', Flor::Journal)
      if unit.conf['sto_uri'].match(/memory/)
        unit.storage.delete_tables
        unit.storage.migrate
      end
      unit.start

      @lines = []
      @payload = {}
      @vars = {}
      @prompt = 'flor> '

      loop do

        line = prompt_and_read(@prompt)

        break unless line
        next if line.strip == ''

        cmd = "cmd_#{line.split(/\s/).first}".to_sym

        if cmd.size > 4 && methods.include?(cmd)
          send(cmd, line)
        else
          @lines << line
        end
      end

      $stdout.puts
    end

    protected

    def cmd_launch(line)

puts "launched..."
    end
    alias cmd_run cmd_launch

    def cmd_help(line)

puts "help..."
    end

    def cmd_exit(line)

      exit(0)
    end

    def cmd_list(line)

      w = [ 2, @lines.size.to_s.length ].max

      @lines.each_with_index do |l, i|
        puts "%0#{w}i  %s" % [ i, l ]
      end
    end

    def cmd_new(line)
# TODO erase lines, payload and vars
    end
    def cmd_save(line)
# TODO save lines (and payload and vars) to a file
    end

    def cmd_cont(line)
# TODO eventually, resume the current execution
    end

    #
    # use Readline if possible

    begin
      require 'readline'
      def prompt_and_read(prompt)
        Readline.readline(@prompt, true)
      end
      COMMANDS = self.allocate.methods \
        .select { |m| m.to_s.match(/^cmd_/) }.collect { |m| m[4..-1] }
      Readline.completion_proc =
        proc { |s| COMMANDS.grep(/^#{Regexp.escape(s)}/) }
      #Readline.completion_append_character =
      #  " "
    rescue LoadError => e
      def prompt_and_read(prompt)
        print(prompt)
        ($stdin.readline rescue false)
      end
    end
  end
end

