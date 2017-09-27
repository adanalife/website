module Overcommit::Hook::PrePush
  class DeploySite < Base
    def run
      system(command, flags.join(' '), out: $stdout, err: :out)
      result = $?
      return :pass if result.success?

      output = result.stdout + result.stderr
      [:fail, output]
    end
  end
end
