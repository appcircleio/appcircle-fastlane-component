require 'open3'

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

runCommand("gem install bundler")

Dir.chdir("#{ac_working_dir}")
runCommand("bundle install")
runCommand("bundle exec fastlane #{ac_fastlane_lane}")

exit 0