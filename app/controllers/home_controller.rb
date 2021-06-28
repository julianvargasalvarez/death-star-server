class HomeController < ApplicationController

  def index

      if team_signed_in?
        render :json => { "links":
          Battle.active.all.map{|battle| battle.as_json(only: [:name]).merge(url: battle_url(battle))}
        }

      else
        render :json => { "main": [
               "Mi talento es el software",
               ],
               "form": {"description": "Este endpoint permite registrar un equipo",
                        "register": teams_url, "via": "POST",
                  "fields": [
                      {"name": "string", "details": "El nombre del equipo debe sonar chevere"},
                      {"url":"string",   "details": "Una url publica hacia donde este api va a publicar la informacion de los sensores"},
                   ],
                  "example": ["In the terminal, write:",
                              " curl -XPOST -H 'content-type: application/json' -d '{\"name\":\"alpha\",\"url\": \"http://alpha.com/listen\"} #{teams_url}",
                              "The api will return a json containing a token that you must pass as header in order to make authenticated requests:",
                              "   {'token':'003e31cb-5b1b-45a9-a87c-bd4d6e7e8343'}   ","",
                              "curl -XGET -H 'content-type: application/json' -H 'Token: 003e31cb-5b1b-45a9-a87c-bd4d6e7e8343' #{root_url}'",
                              "",
                              "If you need to update your team's data, perform a PUT request sending new name and url:",
                              "",
                              "     curl -XPUT -H 'content-type: application/json' -H 'Token: <my-token>' -d '{\"name\":\"new name\",\"url\":\"http://new-url.com/ingress/\"}' #{teams_url} ",
                              "",
                              "The api will return a json with the new data"]
               }
          }
      end

  end

end
