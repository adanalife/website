module Overcommit::Hook::PrePush
  class DeploySite < Base
    def run
      if Overcommit::GitRepo.current_branch != 'master'
        return [:pass, 'Skipping non-master branch']
      end

      system(command, flags.join(' '), out: $stdout, err: :out)
      result = $?
      return :pass if result.success?

      output = result.stdout + result.stderr
      [:fail, output]
    end
  end
end
