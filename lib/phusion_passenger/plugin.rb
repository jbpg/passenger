#  Phusion Passenger - http://www.modrails.com/
#  Copyright (c) 2010 Phusion
#
#  "Phusion Passenger" is a trademark of Hongli Lai & Ninh Bui.
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.

require 'phusion_passenger'
require 'etc'

module PhusionPassenger

class Plugin
	@@hooks = {}
	
	def self.load(name, load_once = true)
		PLUGIN_DIRS.each do |plugin_dir|
			if plugin_dir =~ /\A~/
				# File.expand_path uses ENV['HOME'] which we don't want.
				home = Etc.getpwuid(Process.uid).dir
				plugin_dir = plugin_dir.sub(/\A~/, home)
			end
			plugin_dir = File.expand_path(plugin_dir)
			Dir["#{plugin_dir}/#{name}/*.rb"].each do |filename|
				if load_once
					require(filename)
				else
					load(filename)
				end
			end
		end
	end
	
	def self.register_hook(name, &block)
		hooks_list = (@@hooks[name] ||= [])
		hooks_list << block
	end
	
	def self.call_hook(name, *args, &block)
		last_result = nil
		if (hooks_list = @@hooks[name])
			hooks_list.each do |callback|
				last_result = callback.call(*args, &block)
			end
		end
		return last_result
	end
end

end # module PhusionPassenger