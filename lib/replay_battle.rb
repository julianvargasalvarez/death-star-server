battle = Battle.find(ARGV[0])
team = Team.find_by(token: ARGV[1])

publish_to = team.url
index = 0
IO.foreach("./batalla#{battle.id}.csv") do |line|
  f = open("./file#{index}","w")
  f.write("{\"data\": \"#{line}\"}")
  f.close
  Process.spawn("curl -XPOST -H 'content-type: application/json' -d @./file#{index} '#{team.url}' --silent && rm file#{index}")
  index += 1
  sleep 1
end
