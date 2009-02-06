module Code
  class Actor < Vertebra::Actor
    provides "/code"

    bind_op "/code/commit", :code_commit
    desc "/code/commit", "Announce the commit in IRC"
    def code_commit(options = {})
      repository = options['repository']
      commit = options["commit"]
      puts "Got a commit for #{repository}"
      pp commit

      topic = commit['message'].split("\n").first
      ref =   commit['id'][0,7]
      author = commit['author']['name']
      message = "[#{repository}] #{topic} - #{ref} - #{author}"

      puts message
      @agent.request("/irc/push", :single, :channel => "#halorgium", :message => message)
      true
    end
  end
end
