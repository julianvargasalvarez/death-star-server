# ships = ['Starfighter','Bomber','Scout vessel','Gunship']
#Battle.destroy_all
Battle.create(name: "Batalla de Siringotlid", status: 'active')
Battle.create(name: "Batalla de Nemunahadr", status: 'active')
Battle.create(name: "Batalla de Famousagin", status: 'active')
Battle.create(name: "V la batalla final", status: 'inactive')

#  batallas      1   2     3     4
#
#sensores = ["-", 3, 10, 180_000, 0]
#duracion = ["-", 1,  1,       1, 2]
sensores = ["-", 1000, 0, 0,  0]
duracion = ["-",    5, 0, 0,  0]

Battle.pluck(:id).each do |battle_id|
  current_date_time = DateTime.now
    # Total number of sensons
    sensores[battle_id].times do |i|
      (60 * duracion[battle_id]).times do |seconds|
        _when = current_date_time + seconds.seconds
  
      puts "insert into measures(\"when\", sensor, ship, magtobossometric_value, is_in_cluster, battle_id, created_at, updated_at) values('#{_when}',#{i+1},'-',#{rand(1..99)},#{false},#{battle_id}, '#{DateTime.now}','#{DateTime.now}');"
    end
  end
end

# 108_000_000 de registros para la batalla final

#hay que transformar la batalla final de sql a archivo plano para servir linea por linea
#
# ships = ['Starfighter','Bomber','Scout vessel','Gunship']
#puts "2021-06-01 08:00:01,".length + "(-,0)".length * 180000
#puts "2021-06-01 08:00:01,".length + "(Scout vessel,2000)".length * 180000
