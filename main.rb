require 'open3'
require 'os'

def get_env_variable(key)
	return (ENV[key] == nil || ENV[key] == "") ? nil : ENV[key]
end

ac_fastlane_lane = get_env_variable("AC_FASTLANE_LANE") || abort('Missing fastlane lane parameter.')
ac_working_dir = get_env_variable("AC_FASTLANE_DIR") || abort('Missing fastlane directory parameter.')

def runCommand(command)
	puts "@@[command] #{command}"
	status = nil
	stdout_str = nil
	stderr_str = nil
	Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
		stdout.each_line do |line|
		puts line
		end
		stdout_str = stdout.read
		stderr_str = stderr.read
		status = wait_thr.value
	end

	unless status.success?
		raise stderr_str
	end
end

Dir.chdir("#{ac_working_dir}")

if File.file?("Gemfile")
	puts "Gemfile exists in working directory."
	runCommand('gem install bundler -v 2.4.22')
	runCommand("bundle install")
	runCommand("bundle exec fastlane --version")
	runCommand("bundle exec fastlane #{ac_fastlane_lane} --verbose")
else
	puts "Gemfile doesn't exist in working directory."
	if OS.mac?
		if `which rbenv`.empty?
			runCommand("sudo gem install fastlane -NV")
		else
			runCommand("gem install fastlane -NV")
		end
	else
		runCommand("gem install fastlane -NV")
	end
	runCommand("fastlane --version")
	runCommand("fastlane #{ac_fastlane_lane} --verbose")
end

exit 0